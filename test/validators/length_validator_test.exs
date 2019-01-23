defmodule PasswordValidator.Validators.LengthValidatorTest do
  use ExUnit.Case, async: true
  import PasswordValidator.Validators.LengthValidator, only: [validate: 2]
  alias PasswordValidator.Validators.LengthValidator

  doctest LengthValidator

  test "invalid configuration" do
    assert_raise RuntimeError, fn ->
      validate("simple", length: [min: 3, max: 2])
    end
  end

  test "a nil password is treated as an empty password" do
    assert validate(nil, length: [min: 1]) ==
             {:error, ["String is too short. Only 0 characters instead of 1"]}
  end

  test "emoji characters are counted as one character" do
    assert validate("🤔12", length: [min: 3, max: 3]) == :ok
  end

  test "an invalid min value raises an error" do
    assert_raise RuntimeError, "min must be an integer", fn ->
      validate("", length: [min: "5"])
    end
  end

  test "an invalid max value raises an error" do
    assert_raise RuntimeError, "max must be an integer", fn ->
      validate("", length: [max: "guild"])
    end
  end
end
