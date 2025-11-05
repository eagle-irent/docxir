defmodule Docxir.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/eagle-irent/docxir"

  def project do
    [
      app: :docxir,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      dialyzer: dialyzer(),
      escript: escript(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:sweet_xml, "~> 0.7"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Converts Microsoft Word (.docx) documents to HTML with Tailwind CSS styling. Preserves formatting (bold, italic, underline, font sizes, colors, alignments) and list structures. Provides both programmatic API and Mix task CLI. Generates clean, responsive HTML ready for web applications.
    """
  end

  defp package do
    [
      name: "docxir",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "Docxir",
      source_url: @source_url,
      extras: ["README.md", "LICENSE"]
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      flags: [:error_handling, :underspecs],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end

  defp escript do
    [
      main_module: Docxir.CLI,
      name: "docxir"
    ]
  end
end
