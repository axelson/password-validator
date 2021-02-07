defmodule PasswordValidator.Utils do
  @spec ok_or_errors(list(:ok | {:error, any()})) :: :ok | {:error, list()}
  def ok_or_errors(list) when is_list(list) do
    Enum.reduce(list, :ok, fn
      :ok, :ok ->
        :ok

      :ok, {:error, items} ->
        {:error, items}

      # First error
      {:error, item}, :ok ->
        {:error, [item]}

      {:error, item}, {:error, items} ->
        {:error, [item | items]}
    end)
    |> case do
      :ok -> :ok
      {:error, items} -> {:error, Enum.reverse(items)}
    end
    |> maybe_format_dynamic()
  end

  @spec collect_errors(list({:ok, any()} | {:error, any()})) :: {:ok, list()} | {:error, list()}
  def collect_errors(list) when is_list(list) do
    Enum.reduce(list, {:ok, []}, fn
      {:ok, item}, {:ok, list} ->
        {:ok, [item | list]}

      {:ok, _}, {:error, messages} ->
        {:error, messages}

      {:error, message}, {:ok, _} ->
        {:error, [message]}

      {:error, message}, {:error, messages} ->
        {:error, [message | messages]}
    end)
    |> case do
      {atom, list} -> {atom, Enum.reverse(list)}
    end
  end

  defp maybe_format_dynamic(:ok) do
    :ok
  end

  defp maybe_format_dynamic(errors) do
    gettext? = Code.ensure_loaded?(Gettext)

    maybe_format_dynamic(gettext?, errors)
  end

  defp maybe_format_dynamic(true, {:error, errors}) do
    {:error,
     Enum.map(errors, fn
       error when is_binary(error) ->
         error

       {error_message, additional_info} ->
         {error_message, additional_info}

       {error_message, additional_info, keys} ->
         {error_message, Keyword.merge(additional_info, keys)}

       error ->
         error
     end)}
  end

  defp maybe_format_dynamic(false, {:error, errors}) do
    {:error,
     Enum.map(errors, fn
       error when is_binary(error) ->
         error

       {error_message, additional_info} ->
         {error_message, additional_info}

       {error_message, additional_info, keys} ->
         dynamic_message = dynamic_message(error_message, keys)
         {dynamic_message, additional_info}

       error ->
         error
     end)}
  end

  defp dynamic_message(message, keys) do
    Regex.replace(~r"%{(\w+)}", message, fn _, key ->
      keys |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
