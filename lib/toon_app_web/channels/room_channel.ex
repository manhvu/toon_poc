defmodule ToonAppWeb.RoomChannel do
  use ToonAppWeb, :channel

  alias ToonApp.GenData

  require Logger

  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_in("get_data", payload, socket) do
    msg = GenData.gen(10)
    {:reply, {:ok, msg}, socket}
  end

  def handle_in("push_data", payload, socket) do
    Logger.debug("received: #{inspect payload}")
    {:reply, {:ok, "received"}, socket}
  end


  @impl true
  def handle_info("push", payload, socket) do
     push(socket, "gen_api_result", payload)
     {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
