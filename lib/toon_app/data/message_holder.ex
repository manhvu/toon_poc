defmodule ToonApp.MessageHolder do
 @moduledoc false

 defstruct [
   :id,
   :messages,
   :datetime
 ]

 alias __MODULE__
 alias ToonApp.Message

 def new(messages) do
   %MessageHolder{
     id: Uniq.UUID.uuid4(),
     datetime: DateTime.utc_now(),
     messages: Enum.map(messages, fn {title, content} -> Message.new(title, content) end)
   }
 end
end
