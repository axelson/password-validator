defmodule PasswordValidator.Validators.CharacterSetValidator.Config do
  @moduledoc false

  defstruct [
    :upper_case,
    :lower_case,
    :numbers,
    :special,
    :allowed_special_characters,
    :custom_messages
  ]

  @type keys :: :upper_case | :lower_case | :numbers | :special

  @type t() :: %__MODULE__{
          upper_case: [:infinity | non_neg_integer()],
          lower_case: [:infinity | non_neg_integer()],
          numbers: [:infinity | non_neg_integer()],
          special: [:infinity | non_neg_integer()],
          allowed_special_characters: :all | String.t() | nil,
          custom_messages: any()
        }

  @spec from_options(list({atom(), any()})) :: t()
  def from_options(opts) do
    config = Keyword.get(opts, :character_set, [])

    %__MODULE__{
      lower_case: character_set_config(config, :lower_case),
      upper_case: character_set_config(config, :upper_case),
      numbers: character_set_config(config, :numbers),
      special: character_set_config(config, :special),
      allowed_special_characters: allowed_special_characters_config(config),
      custom_messages: Keyword.get(config, :messages, [])
    }
  end

  @spec character_set_config(list(), keys()) :: list(integer() | :infinity)
  defp character_set_config(opts, key) do
    option = Keyword.get(opts, key, [0, :infinity])

    case option do
      number when is_integer(number) -> [number, :infinity]
      [min, max] when is_integer(min) and is_integer(max) -> [min, max]
      [min, :infinity] when is_integer(min) -> [min, :infinity]
      _ -> raise "Invalid configuration"
    end
  end

  @spec allowed_special_characters_config(list()) :: String.t() | :all
  defp allowed_special_characters_config(opts) do
    case Keyword.get(opts, :allowed_special_characters, :all) do
      allowed_characters when is_binary(allowed_characters) ->
        allowed_characters

      :all ->
        :all

      invalid_config ->
        raise "Invalid allowed_special_characters config. Got: #{inspect(invalid_config)} when a binary (string) was expected"
    end
  end
end
