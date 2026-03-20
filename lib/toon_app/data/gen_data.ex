defmodule ToonApp.GenData do
@moduledoc false

  def gen(n \\ 1) do
    msgs = Enum.map(1..n, fn i -> {"Title #{i}", "Content for message #{i}"} end)
    ToonApp.MessageHolder.new( msgs)
  end

end
