defmodule PasswordValidatorDataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import PasswordValidatorDataCase
    end
  end

  @doc """
  A helper that transforms changeset or list errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(errors) when is_list(errors) do
    Enum.map(errors, fn
      {message, keys} ->
        Regex.replace(~r"%{(\w+)}", message, fn _, key ->
          keys |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)

      error ->
        error
    end)
  end

  def errors_on(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
