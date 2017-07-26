defmodule PasswordValidator.Validators.CharacterSetValidatorTest do
  use ExUnit.Case, async: true
  import PasswordValidator.Validators.CharacterSetValidator, only: [validate: 2]
  alias PasswordValidator.Validators.CharacterSetValidator

  doctest CharacterSetValidator

  test "upper_case 2" do
    opts = [character_set: [upper_case: 2]]
    result = validate("String", opts)
    assert result == [error: "Not enough upper_case characters (got 1 needed 2)"]
  end

  test "upper_case [0, 2]" do
    opts = [character_set: [upper_case: [0, 2]]]
    result = validate("String", opts)
    assert result == :ok
  end

  test "lower_case" do
    opts = [character_set: [lower_case: [1, :infinity]]]
    result = validate("String", opts)
    assert result == :ok
  end

  test "special characters" do
    opts = [character_set: [allowed_special_characters: "!-_"]]
    result = validate("String_speci@l%", opts)
    assert result == [error: "Invalid character(s) found. (@%)"]
  end

  test "multiple errors" do
    opts = [character_set: [
      allowed_special_characters: "!-_",
      special: 3,
    ]]
    result = validate("String_speci@l%", opts)
    assert result == [
      error: "Not enough special characters (got 1 needed 3)",
      error: "Invalid character(s) found. (@%)",
    ]
  end

end
