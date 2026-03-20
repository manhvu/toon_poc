
defimpl Jason.Encoder, for: ToonApp.Message do
  def encode(message, opts) do
    %{
      "id" => message.id,
      "datetime" => DateTime.to_string(message.datetime),
      "title" => message.title,
      "content" => message.content
    }
    |> Jason.Encode.map(opts)
  end
end

defimpl Jason.Encoder, for: ToonApp.MessageHolder do
  def encode(message_holder, opts) do
    %{
      "id" => message_holder.id,
      "datetime" => DateTime.to_string(message_holder.datetime),
      "messages" =>Enum.map(message_holder.messages,
        fn message ->
          {:ok, value} = Jason.encode(message)
          value
        end)
    }
    |> Jason.Encode.map(opts)
  end
end
