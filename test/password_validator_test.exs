defmodule PasswordValidatorTest do
  use ExUnit.Case, async: true
  doctest PasswordValidator

  describe "validate/3" do
    test "validate with a valid string returns a valid changeset" do
      changeset = validate("Bob")

      assert changeset.valid?
    end

    test "validate with one error returns an invalid changeset" do
      opts = [length: [max: 6]]

      changeset = validate("Passw0rd", opts)

      refute changeset.valid?
      assert errors_on(changeset) == %{password: ["String is too long"]}
    end

    test "validate with two errors returns an invalid changeset" do
      opts = [
        length: [min: 9],
        character_set: [numbers: 3],
      ]

      changeset = validate("S3cr3t", opts)

      refute changeset.valid?
      assert errors_on(changeset) == %{
        password: [
          "Not enough numbers characters (got 2 needed 3)",
          "String is too short",
        ]
      }
    end
  end

  test "validate_password with no options always passes" do
    assert :ok = PasswordValidator.validate_password("some password")
  end

  test "validate_password length too short" do
    opts = [length: [min: 8]]
    assert {:error, reasons} = PasswordValidator.validate_password("short", opts)
    assert "String is too short" in reasons
  end

  test "validate_password length too long" do
    opts = [length: [max: 6]]
    assert {:error, reasons} = PasswordValidator.validate_password("way too long", opts)
    assert "String is too long" in reasons
  end

  test "validate_password with invalid options" do
    opts = [length: [min: 20, max: 10]]
    assert_raise RuntimeError, "Min length cannot be shorter than the max", fn ->
      PasswordValidator.validate_password("some password", opts)
    end
  end

  test "validate_password with errors on multiple validators" do
    opts = [
      length: [min: 7],
      character_set: [upper_case: 1]
    ]
    result = PasswordValidator.validate_password("short", opts)
    assert result == {:error, ["String is too short", "Not enough upper_case characters (got 0 needed 1)"]}
  end

  defp validate(password, opts \\ []) do
    {%{password: password}, password: :string}
    |> Ecto.Changeset.change
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
