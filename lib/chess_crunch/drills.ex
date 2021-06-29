defmodule ChessCrunch.Drills do
  @moduledoc """
  The Drills context.
  """

  import Ecto.Query, warn: false
  alias ChessCrunch.{ImageStorage, Repo}

  alias ChessCrunch.Drills.Drill

  @doc """
  Returns the list of drills.

  ## Examples

      iex> list_drills()
      [%Drill{}, ...]

  """
  def list_drills do
    Repo.all(Drill)
  end

  @doc """
  Gets a single drill.

  Raises `Ecto.NoResultsError` if the Drill does not exist.

  ## Examples

      iex> get_drill!(123)
      %Drill{}

      iex> get_drill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_drill!(id), do: Repo.get!(Drill, id)

  @doc """
  Creates a drill.

  ## Examples

      iex> create_drill(%{field: value})
      {:ok, %Drill{}}

      iex> create_drill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_drill(attrs \\ %{}) do
    %Drill{}
    |> Drill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a drill.

  ## Examples

      iex> delete_drill(drill)
      {:ok, %Drill{}}

      iex> delete_drill(drill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_drill(%Drill{} = drill) do
    Repo.delete(drill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking drill changes.

  ## Examples

      iex> change_drill(drill)
      %Ecto.Changeset{data: %Drill{}}

  """
  def change_drill(%Drill{} = drill, attrs \\ %{}) do
    Drill.changeset(drill, attrs)
  end
end