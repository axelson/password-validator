defmodule PasswordValidator do
  @moduledoc """
  PasswordValidator makes it easy to validate passwords.
  """

  alias PasswordValidator.Validators

  @validators [
    Validators.LengthValidator,
    Validators.CharacterSetValidator,
  ]

  @spec validate(%Ecto.Changeset{}, atom(), list()) :: %Ecto.Changeset{}
  def validate(changeset, field, opts \\ []) do
    password = Ecto.Changeset.get_field(changeset, field)
    case validate_password(password, opts) do
      :ok -> changeset
      {:error, errors} ->
        Enum.reduce(errors, changeset, fn (error, cset) ->
          Ecto.Changeset.add_error(cset, field, error)
        end)
    end
  end

  def validate_password(password, opts \\ []) do
    results =
      @validators
      |> Enum.map(& run_validator(&1, password, opts))

    errors = for({:error, reason} <- results, do: reason)
    |> List.flatten
    if length(errors) > 0 do
      {:error, errors}
    else
      :ok
    end
  end

  defp run_validator(validator, password, opts) do
    apply(validator, :validate, [password, opts])
  end
end
