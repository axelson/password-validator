defmodule PasswordValidator do
  @moduledoc """
  Primary interface to PasswordValidator. The two main methods are `validate/3`
  and `validate_password/2`.

  ## Examples

      iex> opts = [
      ...>   length: [max: 6],
      ...> ]
      iex> PasswordValidator.validate_password("too_long", opts)
      {:error, ["String is too long. 8 but maximum is 6"]}

      iex> opts = [
      ...>   length: [min: 5, max: 30],
      ...>   character_set: [
      ...>     lower_case: 1,  # at least one lower case letter
      ...>     upper_case: [3, :infinity], # at least three upper case letters
      ...>     numbers: [0, 4],  # at most 4 numbers
      ...>     special: [0, 0],  # no special characters allowed
      ...>   ]
      ...> ]
      iex> changeset = Ecto.Changeset.change({%{password: "Simple_pass12345"}, %{}}, %{})
      iex> changeset = PasswordValidator.validate(changeset, :password, opts)
      iex> changeset.errors
      [password: {"Too many special (1 but maximum is 0)", []},
      password: {"Too many numbers (5 but maximum is 4)", []},
      password: {"Not enough upper_case characters (only 1 instead of at least 3)", []}]
  """

  alias PasswordValidator.Validators

  @validators [
    Validators.LengthValidator,
    Validators.CharacterSetValidator
  ]

  @spec validate(Ecto.Changeset.t(), atom(), list()) :: Ecto.Changeset.t()
  def validate(changeset, field, opts \\ []) do
    password = Ecto.Changeset.get_field(changeset, field)

    case validate_password(password, opts) do
      :ok ->
        changeset

      {:error, errors} ->
        Enum.reduce(errors, changeset, fn error, cset ->
          Ecto.Changeset.add_error(cset, field, error)
        end)
    end
  end

  @spec validate_password(String.t(), list()) :: :ok | {:error, nonempty_list()}
  def validate_password(password, opts \\ []) do
    results =
      validators(opts)
      |> Enum.map(&run_validator(&1, password, opts))

    errors =
      for({:error, reason} <- results, do: reason)
      |> List.flatten()

    if length(errors) > 0 do
      {:error, errors}
    else
      :ok
    end
  end

  defp run_validator(validator, password, opts) do
    apply(validator, :validate, [password, opts])
  end

  defp validators(opts) do
    additional_validators(opts)
    |> Enum.concat(@validators)
  end

  defp additional_validators(opts) do
    case Keyword.get(opts, :additional_validators, []) do
      validators when is_list(validators) -> validators
      non_list -> raise "Expected a list of validators, instead received #{inspect(non_list)}"
    end
  end
end
