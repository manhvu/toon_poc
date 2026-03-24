defmodule Client.Worker do
  @moduledoc """
  A `GenServer` that manages a persistent Phoenix Channel connection.

  ## Responsibilities

  * Opens a `PhoenixClient.Socket` from application config on startup.
  * Joins a configurable topic (default `"room:lobby"`).
  * Provides a synchronous and asynchronous API for pushing events.
  * Supports runtime channel switching (leave / join).
  * Exposes introspection helpers (`status/0`, `current_topic/0`).

  ## Configuration

      config :client,
        default_config: [
          url: "ws://localhost:4000/socket/websocket?vsn=2.0.0",
          json_parser: Client.MyToon
        ]

  ## Example

      {:ok, _} = Client.Worker.start_link()

      # fire-and-forget
      Client.Worker.push_async("new_msg", %{body: "hello"})

      # wait for a reply
      {:ok, reply} = Client.Worker.push("new_msg", %{body: "hello"})

      # switch rooms at runtime
      :ok = Client.Worker.join("room:other")
  """

  use GenServer
  require Logger

  alias PhoenixClient.{Channel, Message, Socket}

  @default_topic "room:lobby"
  @socket_boot_delay_ms 200

  # ------------------------------------------------------------------
  # Public API
  # ------------------------------------------------------------------

  @doc """
  Starts the Worker and registers it under its module name.

  Reads connection options from `Application.get_env(:client, :default_config)`
  when no `opts` are given.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Pushes `event` with `payload` on the current channel without waiting
  for a reply (cast semantics).
  """
  @spec push_async(String.t(), map()) :: :ok
  def push_async(event, payload \\ %{}),
    do: GenServer.cast(__MODULE__, {:push_async, event, payload})

  @doc """
  Pushes `event` with `payload` and blocks until the server replies or
  `timeout` milliseconds elapse.

  Returns `{:ok, reply_payload}` or `{:error, reason}`.
  """
  @spec push(String.t(), map(), timeout()) :: {:ok, map()} | {:error, term()}
  def push(event, payload \\ %{}, timeout \\ 5_000),
    do: GenServer.call(__MODULE__, {:push, event, payload}, timeout)

  def get_data(), do: push("get_data")

  @doc """
  Leaves the current channel and joins `topic`.

  Returns `:ok` on success, `{:error, reason}` otherwise.
  """
  @spec join(String.t()) :: :ok | {:error, term()}
  def join(topic),
    do: GenServer.call(__MODULE__, {:join, topic})

  @doc """
  Leaves the current channel gracefully.
  """
  @spec leave() :: :ok
  def leave(),
    do: GenServer.call(__MODULE__, :leave)

  @doc """
  Returns the topic string of the currently joined channel, or `nil`
  when no channel is active.
  """
  @spec current_topic() :: String.t() | nil
  def current_topic(),
    do: GenServer.call(__MODULE__, :current_topic)

  @doc """
  Returns a map with connection status information:

      %{
        connected?: boolean(),
        topic:      String.t() | nil
      }
  """
  @spec status() :: %{connected?: boolean(), topic: String.t() | nil}
  def status(),
    do: GenServer.call(__MODULE__, :status)

  @doc """
  Pushes `event` with `payload` and passes the reply to `callback/1`
  once it arrives.  Returns `:ok` immediately (non-blocking).

  The callback runs inside the Worker process — keep it short.
  """
  @spec push_with_callback(String.t(), map(), (term() -> any())) :: :ok
  def push_with_callback(event, payload, callback) when is_function(callback, 1),
    do: GenServer.cast(__MODULE__, {:push_with_callback, event, payload, callback})

  # ------------------------------------------------------------------
  # GenServer callbacks
  # ------------------------------------------------------------------

  @impl true
  def init(opts) do
    config = opts_or_app_config(opts)
    topic = Keyword.get(config, :topic, @default_topic)

    Logger.info("Worker: config: #{inspect(config)}, topic: #{inspect(topic)}")

    {:ok, socket} = Socket.start_link(config)
    # Give the socket time to complete the WebSocket handshake.
    Process.sleep(@socket_boot_delay_ms)

    case Channel.join(socket, topic) do
      {:ok, _response, channel} ->
        Logger.info("Worker: joined #{topic}")
        {:ok, build_state(socket, channel, topic)}

      {:error, reason} ->
        Logger.error("Worker: failed to join #{topic}: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_call({:push, event, payload}, _from, %{channel: channel} = state) do
    result =
      case Channel.push(channel, event, payload) do
        {:ok, reply} -> {:ok, reply}
        {:error, _} = e -> e
      end

    {:reply, result, state}
  end

  def handle_call({:join, topic}, _from, %{socket: socket, channel: old_channel} = state) do
    with :ok <- leave_channel(old_channel),
         {:ok, _resp, new_channel} <- Channel.join(socket, topic) do
      Logger.info("Worker: switched to #{topic}")
      {:reply, :ok, build_state(socket, new_channel, topic)}
    else
      {:error, reason} = err ->
        Logger.error("Worker: failed to join #{topic}: #{inspect(reason)}")
        {:reply, err, state}
    end
  end

  def handle_call(:leave, _from, %{channel: channel} = state) do
    leave_channel(channel)
    {:reply, :ok, %{state | channel: nil, topic: nil}}
  end

  def handle_call(:current_topic, _from, state),
    do: {:reply, state.topic, state}

  def handle_call(:status, _from, %{socket: socket} = state) do
    info = %{
      connected?: Socket.connected?(socket),
      topic: state.topic
    }

    {:reply, info, state}
  end

  @impl true
  def handle_cast({:push_async, event, payload}, %{channel: channel} = state) do
    Channel.push_async(channel, event, payload)
    {:noreply, state}
  end

  def handle_cast({:push_with_callback, event, payload, cb}, %{channel: channel} = state) do
    case Channel.push(channel, event, payload) do
      {:ok, reply} -> cb.({:ok, reply})
      {:error, _} = e -> cb.(e)
    end

    {:noreply, state}
  end

  @impl true
  # Phoenix framework error signal from the server side.
  def handle_info(%Message{event: "phx_error", payload: payload}, state) do
    Logger.error("Worker: server error: #{inspect(payload)}")
    {:noreply, state}
  end

  # Channel was closed by the server (e.g. topic deleted).
  def handle_info(%Message{event: "phx_close", payload: _payload}, state) do
    Logger.warning("Worker: channel closed by server")
    {:noreply, %{state | channel: nil, topic: nil}}
  end

  # All other incoming channel events.
  def handle_info(%Message{event: event, payload: payload}, state) do
    Logger.debug("Worker: event=#{event} payload=#{inspect(payload)}")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.warning("Worker: unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end

  # ------------------------------------------------------------------
  # Private helpers
  # ------------------------------------------------------------------

  defp opts_or_app_config([]), do: Application.fetch_env!(:client, :default_config)
  defp opts_or_app_config(opts), do: opts

  defp build_state(socket, channel, topic),
    do: %{socket: socket, channel: channel, topic: topic}

  defp leave_channel(nil), do: :ok

  defp leave_channel(channel) do
    case Channel.leave(channel) do
      :ok -> :ok
      {:error, _} = e -> e
    end
  end
end
