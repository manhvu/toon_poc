defmodule ToonApp.Message do
 @moduledoc false

 defstruct [
   :id,
   :title,
   :content,
   :datetime
 ]

 alias __MODULE__

 def new(title, content) do
   %__MODULE__{
     id: Uniq.UUID.uuid4(),
     title: title,
     content: content,
     datetime: DateTime.utc_now()
   }
 end



end
