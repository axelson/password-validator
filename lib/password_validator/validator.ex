defmodule PasswordValidator.Validator do
  @moduledoc """
  Specifies the behaviour needed to implement a custom (or built-in) validator.
  """

  @doc """
  Validate the given string and return `:ok` or `{:error, errors}` where
  `errors` is a list.
  """
  @callback validate(String.t(), Keyword.t()) :: :ok | {:error, nonempty_list()}

  @spec return_errors_or_ok(list()) :: :ok | {:error, nonempty_list()}
  def return_errors_or_ok(results) do
    errors = for {:error, reason} <- results, do: reason

    case errors do
      [] -> :ok
      _ -> {:error, errors}
    end
  end
end
