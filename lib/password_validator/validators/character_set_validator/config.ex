defmodule PasswordValidator.Validators.CharacterSetValidator.Config do
  defstruct [:upper_case, :lower_case, :numbers, :special, :allowed_special_characters]

  def from_options(opts) do
    config = Keyword.get(opts, :character_set, [])

    %__MODULE__{
      lower_case: character_set_config(config, :lower_case),
      upper_case: character_set_config(config, :upper_case),
      numbers: character_set_config(config, :numbers),
      special: character_set_config(config, :special),
      allowed_special_characters: allowed_special_characters_config(config)
    }
  end

  defp character_set_config(opts, key) do
    option = Keyword.get(opts, key, [0, :infinity])
    case option do
      number when is_integer(number) -> [number, :infinity]
      [min, max] when is_integer(min) and is_integer(max) -> [min, max]
      [min, :infinity] when is_integer(min) -> [min, :infinity]
      _ -> raise "Invalid configuration"
    end
  end

  defp allowed_special_characters_config(opts) do
    Keyword.get(opts, :allowed_special_characters, :all)
  end
end
