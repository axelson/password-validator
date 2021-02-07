defmodule PasswordValidator.Validators.CharacterSetValidator do
  @moduledoc """
  Validates a password by checking the different types of characters contained
  within.
  """

  @behaviour PasswordValidator.Validator

  @initial_counts %{
    upper_case: 0,
    lower_case: 0,
    numbers: 0,
    special: 0,
    other: []
  }

  @character_sets [:lower_case, :upper_case, :numbers, :special]

  alias PasswordValidator.Validators.CharacterSetValidator.Config

  @doc """
  Example config
  [
    character_set: [
      # Require at least 1 upper case letter
      upper_case: [1, :infinity],
      # Require at least 1 lower case letter
      lower_case: 1,
      # Require at least 1 number
      numbers: 1,
      # Require exactly 0 special characters
      special: [0, 0],
      # Specify which special characters are allowed (default is :all)
      allowed_special_characters: "!@#$%^&*()",
    ]
  ]
  """
  def validate(_, []), do: :ok

  def validate(string, opts) when is_list(opts) do
    config = Config.from_options(opts)
    validate_password(string, config)
  end

  defp validate_password(nil, %Config{} = config) do
    validate_password("", config)
  end

  @spec validate_password(String.t(), %Config{}) :: :ok | {:error, nonempty_list()}
  defp validate_password(string, %Config{} = config) do
    counts = count_character_sets(string, config.allowed_special_characters)

    @character_sets
    |> Enum.map(&validate_character_set(&1, counts, config))
    |> Enum.concat([validate_other(counts)])
    |> Enum.map(& interpret_additional_info(&1, config.custom_messages))
    |> PasswordValidator.Validator.return_errors_or_ok()
  end

  def interpret_additional_info({_, :ok}, _custom_messages), do: :ok

  def interpret_additional_info({type, {:error, sub_type, reason}}, custom_messages) do
    error_type = error_type(type, sub_type)
    reason = Keyword.get(custom_messages, error_type, reason)
    additional_info = [validator: __MODULE__, error_type: error_type]
    {:error, {reason, additional_info}}
  end

  defp error_type(:other, :invalid), do: :invalid_special_characters

  defp error_type(type, sub_type) do
    String.to_atom("#{sub_type}_#{type}")
  end

  @spec validate_character_set(atom(), map(), %Config{}) ::
          {atom(), :ok} | {atom(), {:error, String.t()}}
  for character_set <- @character_sets do
    def validate_character_set(
          unquote(character_set),
          %{unquote(character_set) => count},
          %Config{unquote(character_set) => character_set_config}
        ) do
      result = do_validate_character_set(unquote(character_set), count, character_set_config)

      {unquote(character_set), result}
    end
  end

  @spec do_validate_character_set(atom(), integer(), list()) :: :ok | {:error, String.t()}
  def do_validate_character_set(character_set, count, config)

  def do_validate_character_set(_, _, [0, :infinity]) do
    :ok
  end

  def do_validate_character_set(_, count, [min, :infinity]) when count > min do
    :ok
  end

  def do_validate_character_set(character_set, count, [min, _]) when count < min do
    {:error, :too_few, "Not enough #{character_set} characters (only #{count} instead of at least #{min})"}
  end

  def do_validate_character_set(character_set, count, [_, max]) when count > max do
    {:error, :too_many, "Too many #{character_set} (#{count} but maximum is #{max})"}
  end

  def do_validate_character_set(_, count, [min, max]) when min <= count and count <= max do
    :ok
  end

  def do_validate_character_set(_, _, config) do
    raise "Invalid character set config. (#{inspect(config)})"
  end

  defp validate_other(%{other: []}),
    do: {:other, :ok}

  defp validate_other(%{other: other_characters}) when length(other_characters) > 0,
    do: {:other, {:error, :invalid, "Invalid character(s) found. (#{other_characters})"}}

  @spec count_character_sets(String.t(), String.t() | nil, map()) :: map()
  defp count_character_sets(string, special_characters, counts \\ @initial_counts)
  defp count_character_sets("", _, counts), do: counts

  defp count_character_sets(string, special_characters, counts) do
    {grapheme, rest} = String.next_grapheme(string)

    counts =
      cond do
        String.match?(grapheme, ~r/[a-z]/) ->
          update_count(counts, :lower_case)

        String.match?(grapheme, ~r/[A-Z]/) ->
          update_count(counts, :upper_case)

        String.match?(grapheme, ~r/[0-9]/) ->
          update_count(counts, :numbers)

        is_special_character(grapheme, special_characters) ->
          update_count(counts, :special)

        true ->
          Map.update!(counts, :other, &Enum.concat(&1, [grapheme]))
      end

    count_character_sets(rest, special_characters, counts)
  end

  @spec update_count(map(), atom()) :: map()
  defp update_count(counts, key) do
    Map.update!(counts, key, &(&1 + 1))
  end

  @spec is_special_character(String.t(), :all | String.t()) :: boolean()
  defp is_special_character(_string, :all), do: true

  defp is_special_character(string, special_characters) when is_binary(special_characters) do
    String.contains?(special_characters, string)
  end
end
