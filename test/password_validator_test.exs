defmodule PasswordValidatorTest do
  use ExUnit.Case, async: true
  doctest PasswordValidator

  @strong_password "shine coin desert"

  describe "validate/3" do
    test "validate with a valid string returns a valid changeset" do
      changeset = validate(@strong_password)

      assert changeset.valid?
    end

    test "validate with one error returns an invalid changeset" do
      opts = [length: [max: 6], zxcvbn: :disabled]

      changeset = validate("Passw0rd", opts)

      refute changeset.valid?
      assert errors_on(changeset) == %{password: ["String is too long. 8 but maximum is 6"]}
    end

    test "validate with two errors returns an invalid changeset" do
      opts = [
        length: [min: 9],
        character_set: [numbers: 3],
        zxcvbn: :disabled
      ]

      changeset = validate("S3cr3t", opts)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               password: [
                 "Not enough numbers characters (only 2 instead of at least 3)",
                 "String is too short. Only 6 characters instead of 9"
               ]
             }
    end
  end

  test "validate_password length too short" do
    opts = [length: [min: 8]]
    assert {:error, reasons} = PasswordValidator.validate_password("short", opts)
    assert "String is too short. Only 5 characters instead of 8" in reasons
  end

  test "validate_password length too long" do
    opts = [length: [max: 6]]
    assert {:error, reasons} = PasswordValidator.validate_password("way too long", opts)
    assert "String is too long. 12 but maximum is 6" in reasons
  end

  test "validate_password with invalid options" do
    opts = [length: [min: 20, max: 10]]

    assert_raise RuntimeError, "Min length cannot be greater than the max", fn ->
      PasswordValidator.validate_password("some password", opts)
    end
  end

  test "validate_password with errors on multiple validators" do
    opts = [
      length: [min: 7],
      character_set: [upper_case: 1]
    ]

    result = PasswordValidator.validate_password("short", opts)

    assert result == {
             :error,
             [
               "String is too short. Only 5 characters instead of 7",
               "Not enough upper_case characters (only 0 instead of at least 1)"
             ]
           }
  end

  test "validate_password works with a custom validator" do
    defmodule CustomValidator do
      @behaviour PasswordValidator.Validator

      def validate(_string, _opts) do
        {:error, ["Invalid password"]}
      end
    end

    result =
      PasswordValidator.validate_password(@strong_password,
        additional_validators: [CustomValidator]
      )

    assert result == {:error, ["Invalid password"]}
  end

  defp validate(password, opts \\ []) do
    {%{password: password}, password: :string}
    |> Ecto.Changeset.change()
    |> PasswordValidator.validate(:password, opts)
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
