
defimpl Toon.Encoder, for: ToonApp.Message do
  def encode(message, opts) do
    %{
      "id" => message.id,
      "datetime" => DateTime.to_string(message.datetime),
      "title" => message.title,
      "content" => message.content
    }
  end
end

defimpl Toon.Encoder, for: ToonApp.MessageHolder do
  def encode(message_holder, opts) do
    %{
      "id" => message_holder.id,
      "datetime" => DateTime.to_string(message_holder.datetime),
      "messages" => message_holder.messages #Enum.map(message_holder.messages, fn message -> Toon.encode!(message, opts) end)
    }
  end
end
