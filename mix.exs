defmodule PropCheck.Derive.MixProject do
  use Mix.Project

  def project do
    [
      app: :propcheck_derive,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {PropCheck.Derive.Application, []}
    ]
  end

  defp deps do
    [
      {:propcheck, "~> 1.2"}
    ]
  end
end
