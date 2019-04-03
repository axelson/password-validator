defmodule PasswordValidator.Validators.ZXCVBNValidator do
  @behaviour PasswordValidator.Validator

  @doc """
  ## Examples

      iex> ZXCVBNValidator.validate("pass")
      {:error, ["This is a top-100 common password"]}
  """
  @impl PasswordValidator.Validator
  def validate(string, opts \\ []) do
    config = Keyword.get(opts, :zxcvbn, [])
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
