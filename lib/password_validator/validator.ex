defmodule PasswordValidator.Validator do
  @callback validate(String.t, list()) :: :ok | {:error, nonempty_list()}

  @spec return_errors_or_ok(list()) :: :ok | {:error, nonempty_list()}
  def return_errors_or_ok(results) do
    errors = for {:error, reason} <- results, do: reason
    if length(errors) == 0 do
      :ok
    else
      {:error, errors}
    end
  end
end
