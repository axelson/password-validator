defmodule PasswordValidator.Validators.CharacterSetValidatorTest do
  use ExUnit.Case, async: true
  import PasswordValidator.Validators.CharacterSetValidator, only: [validate: 2]
  alias PasswordValidator.Validators.CharacterSetValidator

  doctest CharacterSetValidator

  test "a nil password is treated as an empty password" do
    opts = [character_set: [upper_case: 1]]
    result = validate(nil, opts)

    assert result ==
             {:error,
              [
                {"Not enough upper_case characters (only 0 instead of at least 1)",
                 validator: CharacterSetValidator, error_type: :too_few_upper_case}
              ]}
  end

  test "upper_case 2" do
    opts = [character_set: [upper_case: 2]]
    result = validate("String", opts)

    assert result ==
             {:error,
              [
                {"Not enough upper_case characters (only 1 instead of at least 2)",
                 validator: CharacterSetValidator, error_type: :too_few_upper_case}
              ]}
  end

  test "upper_case [0, 2] ok" do
    opts = [character_set: [upper_case: [0, 2]]]
    result = validate("String", opts)
    assert result == :ok
  end

  test "upper_case [0, 2] too many" do
    opts = [character_set: [upper_case: [0, 2]]]
    result = validate("STRING", opts)

    assert result ==
             {:error,
              [
                {"Too many upper_case (6 but maximum is 2)",
                 validator: CharacterSetValidator, error_type: :too_many_upper_case}
              ]}
  end

  test "lower_case" do
    opts = [character_set: [lower_case: [1, :infinity]]]
    result = validate("String", opts)
    assert result == :ok
  end

  test "lower_case with a custom error message" do
    opts = [character_set: [lower_case: 10, messages: [too_few_lower_case: "way too few"]]]
    result = validate("String", opts)

    assert result ==
             {:error,
              [
                {"way too few",
                 [validator: CharacterSetValidator, error_type: :too_few_lower_case]}
              ]}
  end

  test "allowed_special_characters when the string contains only allowed characters" do
    opts = [character_set: [allowed_special_characters: "!-_"]]
    assert validate("Spec-ial!", opts) == :ok
  end

  test "allowed_special_characters when the string contains non-allowed characters" do
    opts = [character_set: [allowed_special_characters: "!-_"]]
    result = validate("String_speci@l%", opts)

    assert result ==
             {:error,
              [
                {"Invalid character(s) found. (@%)",
                 validator: CharacterSetValidator, error_type: :invalid_special_characters}
              ]}
  end

  test "multiple errors" do
    opts = [
      character_set: [
        allowed_special_characters: "!-_",
        special: 3
      ]
    ]

    result = validate("String_speci@l%", opts)

    assert result ==
             {:error,
              [
                {"Not enough special characters (only 1 instead of at least 3)",
                 validator: CharacterSetValidator, error_type: :too_few_special},
                {"Invalid character(s) found. (@%)",
                 validator: CharacterSetValidator, error_type: :invalid_special_characters}
              ]}
  end

  test "with an invalid allowed_special_characters_config" do
    opts = [
      character_set: [
        allowed_special_characters: %{a: true}
      ]
    ]

    error_message =
      "Invalid allowed_special_characters config. Got: %{a: true} when a binary (string) was expected"

    assert_raise RuntimeError, error_message, fn ->
      validate("str@", opts)
    end
  end
end
