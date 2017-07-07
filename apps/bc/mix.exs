defmodule BC.Mixfile do
  use Mix.Project

  def project do
    [app: :bc,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {BC, []}]
  end

  defp deps do
    []
  end
end
