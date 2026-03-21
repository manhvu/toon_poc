defmodule ToonApp.MyToon do
  # basicly, ignore options.

  require Logger

  def encode(data, _opts \\ []) do
    result = Toon.encode(data)
    Logger.debug("encoded, result: #{inspect result}")
    result
  end

  def encode!(data, _opts \\ []) do
    result  = Toon.encode!(data)
    Logger.debug("encoded, result: #{inspect result}")
    result
  end

  def encode_to_iodata!(data, _opts \\ []) do
    result  = Toon.encode_to_iodata!(data)
    Logger.debug("encoded, result: #{inspect result}")
    result
  end

  def decode(data, _opts \\ []) do
    Logger.debug("decoding #{inspect data}")
    result = Toon.decode(data)
    Logger.debug("decoded, result: #{inspect result}")
    result
  end

  def decode!(data, _opts \\ []) do
    Logger.debug("decoding #{inspect data}")
    result = Toon.decode!(data)
    Logger.debug("decoded, result: #{inspect result}")
    result
  end
end
