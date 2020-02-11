defmodule PropCheck.Derive.MixProject do
  use Mix.Project

  def project do
    [
      app: :propcheck_derive,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      source_url: "https://github.com/evnu/propcheck_derive",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
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
      {:propcheck, "~> 1.2"},
      {:docception, "~> 0.3", only: [:dev, :test]},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev},
    ]
  end

  defp description do
    "Derive PropCheck generators from types "
  end

  defp package do
    [
      licenses: ["GPL-3.0-only"],
      links: %{"Github" => "https://github.com/evnu/propcheck_derive"},
      maintainers: ["evnu"]
    ]
  end
end
