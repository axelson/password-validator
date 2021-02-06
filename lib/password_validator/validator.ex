defmodule PasswordValidator.Validator do
  @moduledoc """
  Specifies the behaviour needed to implement a custom (or built-in) validator.
  """

  @type error_info :: String.t() | {String.t(), Keyword.t()}

  @doc """
  Validate the given string and return `:ok` or `{:error, errors}` where
  `errors` is a list.
  """
  @callback validate(String.t(), Keyword.t()) ::
              :ok | {:error, nonempty_list(error_info)}

  @spec return_errors_or_ok(list()) :: :ok | {:error, nonempty_list()}
  def return_errors_or_ok(results) do
    PasswordValidator.Utils.ok_or_errors(results)
  end

  def return_errors_or_ok_old(results) do
    errors = for {:error, reason} <- results, do: reason

    _example_error_info = [
      validator: PasswordValidator.Validators.CharacterSetValidator,
      error_type: :upper_case_too_long
    ]

    case errors do
      [] -> :ok
      _ -> {:error, errors}
    end
  end
end
