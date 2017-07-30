defmodule PasswordValidator.Validators.LengthValidatorTest do
  use ExUnit.Case, async: true
  import PasswordValidator.Validators.LengthValidator, only: [validate: 2]
  alias PasswordValidator.Validators.LengthValidator

  doctest LengthValidator

  test "invalid configuration" do
    assert_raise RuntimeError, fn ->
      validate("simple", [length: [min: 3, max: 2]])
    end
  end

  test "emoji characters are counted as one character" do
    assert validate("🤔12", [length: [min: 3, max: 3]]) == :ok
  end
end
