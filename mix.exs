defmodule PasswordValidator.Mixfile do
  use Mix.Project

  @source_url "https://github.com/axelson/password-validator"
  @version "0.4.1"

  def project do
    [
      app: :password_validator,
      name: "Password Validator",
      version: @version,
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      dialyzer: [flags: ["-Wunmatched_returns", :error_handling, :race_conditions]]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def package do
    [
      description:
        "A library to validate passwords, with built-in validators for password " <>
          "length as well as the character sets used. Custom validators can also be created.",
      name: :password_validator,
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*.md"],
      maintainers: ["Jason Axelson"],
      licenses: ["Apache-2.0"],
      links: %{
        "Changelog" => "https://hexdocs.pm/password_validator/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp deps do
    [
      {:mix_machine, "~> 0.1.0"},
      {:ecto, "~> 2.1 or ~> 3.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:docception, github: "evnu/docception", branch: "master", only: [:test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      canonical: "https://hexdocs.pm/password_validator",
      source_url: @source_url,
      source_ref: "v#{@version}",
      homepage_url: @source_url,
      formatters: ["html"],
      nest_modules_by_prefix: [PasswordValidator.Validators]
    ]
  end
end
