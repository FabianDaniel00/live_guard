defmodule LiveGuard.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_guard,
      description: "Protect LiveView lifecycle stages easily.",
      version: "0.1.8",
      elixir: "~> 1.16.0",
      source_url: "https://github.com/FabianDaniel00/live_guard",
      homepage_url: "https://github.com/FabianDaniel00/live_guard",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: [
        maintainers: ["Daniel Fabian"],
        files:
          ~w(.github config lib test .formatter.exs .gitignore CHANGELOG.md LICENSE mix.exs mix.lock README.md),
        links: %{"GitHub" => "https://github.com/FabianDaniel00/live_guard"},
        licenses: ["MIT"]
      ],
      deps: deps(),
      name: "Live Guard",
      consolidate_protocols: false,
      docs: [
        # The main page in the docs
        main: "readme",
        extras: ["README.md", "CHANGELOG.md"],
        extra_section: "GUIDES"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {LiveGuardTestApplication, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 0.20.3"},
      {:ex_doc, "~> 0.31.0", only: :dev, runtime: false},
      {:floki, "~> 0.35.2", only: :test}
    ]
  end
end
