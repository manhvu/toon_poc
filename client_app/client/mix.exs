defmodule Client.MixProject do
  use Mix.Project

  def project do
    [
      app: :client,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      consolidate_protocols: false,
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_client, "~> 0.11"},
      # {:toon, "~> 0.3"},
      {:toon, path: "../../../toon_ex"},
      {:jason, ">= 0.0.0"}
    ]
  end
end
