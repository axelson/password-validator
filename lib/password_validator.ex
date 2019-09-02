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
      ...>   ],
      ...>   zxcvbn: [
      ...>     min_score: 2, # A number from 1-4. 1 being a simple password, and 4
      ...>                   # being complex
      ...>     user_inputs: ["bob@gmail.com"] # A list of inputs related to the
      ...>                                    # user, such as name and emails (to verify that
      ...>                                    # their password is not too similar to them)
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

  @spec validate(%Ecto.Changeset{}, atom(), list()) :: %Ecto.Changeset{}
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
    opts
    |> Keyword.get(:additional_validators, [])
    |> Enum.concat(@validators)
  end
end
