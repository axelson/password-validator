defmodule AppTest do
  use ExUnit.Case
  alias PasswordValidator.Validators.LengthValidator

  doctest App

  test "minimum password length is checked" do
    assert LengthValidator.validate("short", [length: [min: 10]]) == :ok
  end
end
