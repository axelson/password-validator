defmodule PasswordValidator.Validators.CharacterSetValidator do
  @behaviour PasswordValidator.Validator

  @initial_counts %{
    upper_case: 0,
    lower_case: 0,
    numbers: 0,
    special: 0,
    other: [],
  }

  @character_sets [:lower_case, :upper_case, :numbers, :special]

  alias PasswordValidator.Validators.CharacterSetValidator.Config


  @doc """
  Example config
  [
    character_set: [
      upper_case: [1, :infinity],
      lower_case: 1,
      numbers: 1,
      special: [0, 0],
      allowed_special_characters: "!@#$%^&*()",
    ]
  ]
  """
  # TODO: Do we need both of these?
  def validate(_, []), do: []
  def validate(_, nil), do: []
  def validate(string, opts) do
    config = Config.from_options(opts)
    validate_password(string, config)
  end

  defp validate_password(string, %Config{} = config) do
    counts = count_character_sets(string, config.allowed_special_characters)

    @character_sets
    |> Enum.map(& validate_character_set(&1, counts, config))
    |> Enum.concat([validate_other(counts)])
    |> return_errors_or_ok()
  end

  defp return_errors_or_ok(results) do
    errors = for {:error, reason} <- results, do: {:error, reason}
    if length(errors) > 0 do
      errors
    else
      :ok
    end
  end


  for character_set <- @character_sets do
    def validate_character_set(
      unquote(character_set),
      %{unquote(character_set) => count},
      %Config{unquote(character_set) => config}
    ) do
      do_validate_character_set(unquote(character_set), count, config)
    end
  end

  def do_validate_character_set(character_set, count, config)
  def do_validate_character_set(_, _, [0, :infinity]) do
    :ok
  end
  def do_validate_character_set(_, count, [min, :infinity]) when count > min do
    :ok
  end
  def do_validate_character_set(character_set, count, [min, _]) when count < min do
    {:error, "Not enough #{character_set} characters (got #{count} needed #{min})"}
  end
  def do_validate_character_set(character_set, count, [_, max]) when count > max do
    {:error, "Too many #{character_set} (got #{count} max was #{max})"}
  end
  def do_validate_character_set(_, count, [min, max]) when min <= count >= max do
    :ok
  end
  def do_validate_character_set(_, _, config) do
    raise "Invalid character set config. (#{inspect config})"
  end

  defp validate_other(%{other: other_characters}) when length(other_characters) == 0,
    do: :ok
  defp validate_other(%{other: other_characters}) when length(other_characters) > 0,
    do: {:error, "Invalid character(s) found. (#{other_characters})"}

  # TODO: make private
  def count_character_sets(string, special_characters \\ nil, counts \\ @initial_counts)
  def count_character_sets("", _, counts), do: counts
  def count_character_sets(string, special_characters, counts) do
    {grapheme, rest} = String.next_grapheme(string)

    counts = cond do
      String.match?(grapheme, ~r/[a-z]/) ->
        update_count(counts, :lower_case)
      String.match?(grapheme, ~r/[A-Z]/) ->
        update_count(counts, :upper_case)
      String.match?(grapheme, ~r/[0-9]/) ->
        update_count(counts, :numbers)
      is_special_character(grapheme, special_characters) ->
        update_count(counts, :special)
      true ->
        Map.update!(counts, :other, & Enum.concat(&1, [grapheme]))
    end

    count_character_sets(rest, special_characters, counts)
  end

  defp update_count(counts, key) do
    Map.update!(counts, key, & &1 + 1)
  end

  defp is_special_character(_string, :all), do: true
  defp is_special_character(string, special_characters) when is_binary(special_characters) do
    String.contains?(special_characters, string)
  end
  defp is_special_character(_, special_characters), do: raise "Invalid special characters config (#{inspect special_characters})"
end
