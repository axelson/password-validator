defmodule PasswordValidator do
  @moduledoc """
  Documentation for PasswordValidator.
  """

  @doc """
  Hello world.

  ## Examples

      iex> PasswordValidator.hello
      :world

  """
  def hello do
    :world
  end

  def validate(changeset, field, opts \\ []) do
    password = Ecto.Changeset.get_field(changeset, field)
    errors = validate_password(password, opts)

    if length(errors) > 0 do
      Enum.reduce(errors, changeset, fn (error, cset) ->
        Ecto.Changeset.add_error(cset, field, error)
      end)
    else
      changeset
    end
  end

  defp validate_password(password, opts) do
    min_length = Keyword.get(opts, :min_length, :infinity)
    max_length = Keyword.get(opts, :max_length, :infinity)

    results = []
    |> Enum.concat(validate_length(password, min_length, max_length))

    for {:error, reason} <- results, do: reason
  end

  @doc """
  Returns ok or error tuple
  """
  def validate_length(string, min, max) do
    length = String.length(string)
    [
      valid_min_length?(length, min),
      valid_max_length?(length, max),
    ]
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

  # Construct as a tree of validations
  # Can use breadth first search
  # Only the first branches in the tree get added as specific reasons to the changeset

  # Is it possible to create a generic validation library?
  # So you can easily plug in different validators?
  # They could each have their own validations
  # Might use a common protocol
end
