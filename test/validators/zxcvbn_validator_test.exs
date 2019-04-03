defmodule PasswordValidator.Validators.ZXCVBNValidatorTest do
  use ExUnit.Case, async: true
  import PasswordValidator.Validators.ZXCVBNValidator, only: [validate: 2]
  alias PasswordValidator.Validators.ZXCVBNValidator

  doctest ZXCVBNValidator

  test "invalid configuration" do
    assert_raise RuntimeError, "ZXCVBN min_score must be between 1 and 4, got -1", fn ->
      validate("a password", zxcvbn: [min_score: -1])
    end
  end

  test "a valid password" do
    assert validate("some given password", zxcvbn: [min_score: 2]) == :ok
  end

  test "a nil password" do
    assert_raise FunctionClauseError, fn ->
      assert validate(nil, []) == :ok
    end
  end

  test "emoji password can be valid" do
    password = "🏆🔥 and words"
    assert validate(password, []) == :ok
  end

  test "a weak password" do
    assert validate("one word", zxcvbn: [min_score: 2]) == :ok

    assert validate("one word", zxcvbn: [min_score: 3]) ==
             {:error, ["Add another word or two. Uncommon words are better."]}
  end

  test "a password that matches a user input gets a low score" do
    password = "myrealname"
    assert {:error, _} = validate(password, zxcvbn: [user_inputs: [password], min_score: 1])
    assert validate(password, zxcvbn: [user_inputs: [], min_score: 1]) == :ok
  end

  test "a password that is similar to a user input is penalized" do
    password = "myrealname123"
    assert validate(password, zxcvbn: [user_inputs: ["myrealname"], min_score: 1]) == :ok
    assert {:error, _} = validate(password, zxcvbn: [user_inputs: ["myrealname"], min_score: 2])
    assert validate(password, zxcvbn: [user_inputs: [], min_score: 4]) == :ok
  end
end
