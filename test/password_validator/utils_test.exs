defmodule PasswordValidator.UtilsTest do
  use ExUnit.Case, async: true

  alias PasswordValidator.Utils

  describe "ok_or_errors/1" do
    import Utils, only: [ok_or_errors: 1]

    test "with a single ok" do
      assert ok_or_errors([:ok]) == :ok
    end

    test "with multiple ok" do
      assert ok_or_errors([:ok, :ok]) == :ok
    end

    test "with a single error" do
      assert ok_or_errors([{:error, "err"}]) == {:error, ["err"]}
    end

    test "with all errors keeps the order" do
      assert ok_or_errors([{:error, "1"}, {:error, 2}]) == {:error, ["1", 2]}
    end

    test "with a mix of ok and errors" do
      assert ok_or_errors([:ok, :ok, {:error, 42}, :ok]) == {:error, [42]}
    end

    test "with some complex errors" do
      assert ok_or_errors([:ok, {:error, {1, 3}}, :ok, {:error, %{a: 42}}]) ==
               {:error, [{1, 3}, %{a: 42}]}
    end

    test "with an empty list" do
      assert ok_or_errors([]) == :ok
    end
  end
end
