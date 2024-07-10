defmodule PasswordValidatorMetaTest do
  use ExUnit.Case, async: true

  for file <- ["README.md"] do
    doctest_file(file)
  end

  test "README.md version is up to date" do
    app = Mix.Project.get!().project()[:app]

    app_version =
      Application.spec(app, :vsn)
      |> to_string()
      |> Version.parse!()

    readme = File.read!("README.md")
    [_, readme_version] = Regex.run(~r/{:#{app}, "(.+)"}/, readme)
    assert String.contains?(readme_version, "#{app_version.major}.#{app_version.minor}")
    assert Version.match?(app_version, readme_version)
  end
end
