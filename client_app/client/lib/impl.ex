defimpl Enumerable, for: Slipstream.Message do
  def count(_),         do: {:ok, 5}
  def member?(_, _),    do: {:error, __MODULE__}
  def slice(_),         do: {:error, __MODULE__}

  def reduce(msg, acc, fun) do
    [
      {"topic",    msg.topic},
      {"event",    msg.event},
      {"ref",      msg.ref},
      {"join_ref", msg.join_ref},
      {"payload",  msg.payload}
    ]
    |> Enumerable.List.reduce(acc, fun)
  end
end

defimpl Toon.Encoder, for: Slipstream.Message do
  def encode(message, opts) do
    [message.join_ref, message.ref, message.topic, message.event, Toon.encode!(message.payload, opts)]
  end
end

# defimpl Toon.Encoder, for: Slipstream.Message do
#   def encode(message, opts) do
#     %{
#       "topic"    => message.topic,
#       "event"    => message.event,
#       "ref"      => message.ref,
#       "join_ref" => message.join_ref,
#       "payload"  => Toon.encode!(message.payload, opts)
#     }

#   end
# end

defmodule Client.TestCompile do
  def test() do
    %Slipstream.Message{
      topic: "room:lobby",
      event: "phx_join",
      payload: %{},
      ref: "1",
      join_ref: "1"
    }

    |> Toon.encode!()
  end
end
