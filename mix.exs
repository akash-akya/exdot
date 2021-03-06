defmodule Exdot.MixProject do
  use Mix.Project

  def project do
    [
      app: :exdot,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Package
      package: package(),
      description: description(),

      # Docs
      source_url: "https://github.com/akash-akya/exdot",
      homepage_url: "https://github.com/akash-akya/exdot",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Elixir abstraction for generating Graphviz dot formatted string"
  end

  defp package do
    [
      maintainers: ["Akash Hiremath"],
      licenses: ["GPL-3.0-or-later"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      links: %{
        GitHub: "https://github.com/akash-akya/exdot"
      }
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
