defmodule Rolyrine.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/sephianl/rolyrine"

  def project do
    [
      app: :rolyrine,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Fast polyline encoding/decoding powered by Rust"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.37.0", runtime: false},
      {:rustler_precompiled, "~> 0.8"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "native", "checksum-*.exs", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
