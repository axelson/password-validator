defmodule PasswordValidator.Validators.ZXCVBNValidator do
  @moduledoc """
  Validates a password's strength by estimating how difficult the password is for a password cracker to crack. Uses multiple dictionaries of common names and popular english words.

  More info:
  * Original javascript library: https://github.com/dropbox/zxcvbn
  * Elixir library: https://github.com/techgaun/zxcvbn-elixir/
  """
  @behaviour PasswordValidator.Validator

  @doc """
  Validate the password by checking if it is similar to common names and words.

  ## Examples

      iex> ZXCVBNValidator.validate("pass")
      {:error, ["This is a top-100 common password"]}

      iex> ZXCVBNValidator.validate("Multi word password", zxcvbn: [min_score: 4])
      :ok
  """
  @impl PasswordValidator.Validator
  def validate(string, opts \\ []) when is_binary(string) do
    config = Keyword.get(opts, :zxcvbn, [])
    if config == :disabled do
      :ok
    else
      user_inputs = Keyword.get(config, :user_inputs, [])
      min_score = Keyword.get(config, :min_score, 2)
      validate_min_score(min_score)

      case ZXCVBN.zxcvbn(string, user_inputs) do
        :error ->
          {:error, ["Unable to check password via ZXCVBN due to an unknown reason"]}

        result ->
          if result.score >= min_score do
            :ok
          else
            {:error, error_message(result)}
          end
      end
    end
  end

  defp error_message(zxcvbn_result) do
    %{feedback: %{warning: warning, suggestions: suggestions}} = zxcvbn_result

    if warning == "" do
      suggestions
    else
      [warning]
    end
  end

  defp validate_min_score(min_score) when min_score >= 1 and min_score <= 4, do: :ok
  defp validate_min_score(min_score), do: raise "ZXCVBN min_score must be between 1 and 4, got #{min_score}"
end
