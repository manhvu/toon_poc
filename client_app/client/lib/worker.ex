defmodule Client.Worker do
  use GenServer

  alias PhoenixClient.{Socket, Channel, Message}

  def push_event(event, msg),  do: GenServer.cast(__MODULE__, {:push_event, event, msg})

  # start_link ...
  def start_link(opts \\ [json_library: Toon, url: "ws://localhost:4000/socket/websocket"]) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    {:ok, socket} = PhoenixClient.Socket.start_link(opts)
    Process.sleep(200)
    {:ok, _response, channel} = Channel.join(socket, "room:lobby")

    {:ok, %{
      channel: channel,
      socket: socket
    }}
  end

  def handle_info(%Message{event: "phx_error", payload: payload}, %{config: ws_info} = state) do
    Logger.error("ws_client_tool: server error: #{inspect(payload)}")
    {:noreply, state}
  end
  def handle_info(%Message{event: event, payload: payload}, state) do
    IO.puts "Event: event, Message: #{inspect payload}"
    {:noreply, state}
  end

  @impl true
  def handle_cast({:push_event, event, msg}, state) do
    PhoenixClient.Channel.push_async(state.channel, event, msg)
    {:noreply, state}
  end
end
