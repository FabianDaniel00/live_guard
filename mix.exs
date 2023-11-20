defmodule LiveGuard.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_guard,
      description: "Protect LiveView lifecycle stages easily.",
      version: "0.1.3",
      elixir: "~> 1.15.7",
      source_url: "https://github.com/FabianDaniel00/live_guard",
      homepage_url: "https://github.com/FabianDaniel00/live_guard",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: [
        maintainers: ["Daniel Fabian"],
        files:
          ~w(lib test .formatter.exs .gitignore CHANGELOG.md LICENSE mix.exs mix.lock README.md),
        links: %{"GitHub" => "https://github.com/FabianDaniel00/live_guard"},
        licenses: ["MIT"]
      ],
      deps: deps(),
      name: "Live Guard",
      consolidate_protocols: false,
      docs: [
        # The main page in the docs
        main: "LiveGuard",
        extras: ["README.md", "CHANGELOG.md"]
      ]
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
      {:phoenix_live_view, "~> 0.20.1"},
      {:ex_doc, "~> 0.30.9", only: :dev, runtime: false}
    ]
  end
end
