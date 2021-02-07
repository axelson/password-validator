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
end
