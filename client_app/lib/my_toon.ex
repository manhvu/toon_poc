defmodule Client.MyToon do
  @moduledoc """
  A thin logging wrapper around the `Toon` serializer.

  Satisfies the `PhoenixClient` JSON-parser contract, which requires
  `encode/2`, `encode!/2`, `decode/2`, and `decode!/2`.  The optional
  `opts` argument is accepted but intentionally ignored so that this
  module can be dropped in wherever a standard JSON library is expected.

  All operations delegate directly to the corresponding `Toon` function
  and emit a `debug`-level log entry with the result.
  """

  require Logger

  @type encode_result :: {:ok, binary()} | {:error, term()}
  @type decode_result :: {:ok, term()} | {:error, term()}

  @doc "Encodes `data` with `Toon`. Returns `{:ok, binary}` or `{:error, reason}`."
  @spec encode(term(), keyword()) :: encode_result()
  def encode(data, _opts \\ []) do
    result = ToonEx.encode(data)
    Logger.debug("MyToon.encode result: #{inspect(result)}")
    result
  end

  @doc "Like `encode/2` but raises on failure."
  @spec encode!(term(), keyword()) :: binary()
  def encode!(data, _opts \\ []) do
    result = ToonEx.encode!(data)
    Logger.debug("MyToon.encode! result: #{inspect(result)}")
    result
  end

  @doc "Decodes `data` with `Toon`. Returns `{:ok, term}` or `{:error, reason}`."
  @spec decode(binary(), keyword()) :: decode_result()
  def decode(data, _opts \\ []) do
    result = ToonEx.decode(data)
    Logger.debug("MyToon.decode result: #{inspect(result)}")
    result
  end

  @doc "Like `decode/2` but raises on failure."
  @spec decode!(binary(), keyword()) :: term()
  def decode!(data, _opts \\ []) do
    result = ToonEx.decode!(data)
    Logger.debug("MyToon.decode! result: #{inspect(result)}")
    result
  end
end
