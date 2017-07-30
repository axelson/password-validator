defmodule PasswordValidator.Validators.LengthValidator do
  @behaviour PasswordValidator.Validator

  @doc """
  Validate the

  Example config (min 5 characters, max 9 characters)
  [
    length: [
      min: 5,
      max: 9,
    ]
  ]

      iex> LengthValidator.validate("simple2", [length: [min: 3]])
      :ok

      iex> LengthValidator.validate("too_short", [length: [min: 10]])
      {:error, ["String is too short"]}

      iex> LengthValidator.validate("too_long", [length: [min: 3, max: 6]])
      {:error, ["String is too long"]}
  """
  def validate(string, opts) do
    config = Keyword.get(opts, :length, [])
    min_length = Keyword.get(config, :min, :infinity)
    max_length = Keyword.get(config, :max, :infinity)

    validate_password(string, min_length, max_length)
  end

  @spec validate_password(String.t, integer(), integer() | :infinity) :: :ok | {:error, nonempty_list()}
  defp validate_password(_, min_length, max_length)
    when is_integer(min_length) and is_integer(max_length) and min_length > max_length, do:
      raise "Min length cannot be shorter than the max"
  defp validate_password(string, min_length, max_length) do
    length = String.length(string)
    [
      valid_min_length?(length, min_length),
      valid_max_length?(length, max_length),
    ]
    |> PasswordValidator.Validator.return_errors_or_ok()
  end

  defp valid_min_length?(_, :infinity),
    do: :ok
  defp valid_min_length?(_, min) when not is_integer(min),
    do: {:error, "min must be integer"}
  defp valid_min_length?(length, min) when length < min,
    do: {:error, "String is too short"}
  defp valid_min_length?(_, _),
    do: :ok

  defp valid_max_length?(_, :infinity),
    do: :ok
  defp valid_max_length?(_, max) when not is_integer(max),
    do: {:error, "max must be integer"}
  defp valid_max_length?(length, max) when length > max,
    do: {:error, "String is too long"}
  defp valid_max_length?(_, _),
    do: :ok
end
