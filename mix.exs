defmodule PasswordValidator.Mixfile do
  use Mix.Project

  @version "0.4.1"

  def project do
    [
      app: :password_validator,
      version: @version,
      description: description(),
      package: package(),
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # dialyzer: [ flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs]],
      dialyzer: [flags: ["-Wunmatched_returns", :error_handling, :race_conditions]],

      # Docs
      name: "Password Validator",
      docs: [
        main: "PasswordValidator",
        canonical: "https://hexdocs.pm/password_validator",
        nest_modules_by_prefix: [PasswordValidator.Validators]
      ],
      source_url: "https://github.com/axelson/password-validator",
      homepage_url: "https://github.com/axelson/password-validator"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  def description do
    """
    A library to validate passwords, with built-in validators for password
    length as well as the character sets used. Custom validators can also be
    created.
    """
  end

  def package do
    [
      name: :password_validator,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jason Axelson"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/axelson/password-validator"}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, "~> 2.1 or ~> 3.0"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
