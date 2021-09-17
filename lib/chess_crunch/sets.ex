defmodule ChessCrunch.Sets do
  @moduledoc """
  The Sets context.
  """

  import Ecto.Query, warn: false
  alias ChessCrunch.Repo
  alias ChessCrunch.Sets.{Position, Set}

  @doc """
  Returns the list of sets.

  ## Examples

      iex> list_sets()
      [%Set{}, ...]

  """
  def list_sets(user) do
    Set
    |> where(user_id: ^user.id)
    |> Repo.all()
  end

  def find_sets_by_ids(ids) do
    Set
    |> where([set], set.id in ^ids)
    |> Repo.all()
  end

  @doc """
  Gets a single set.

  Raises `Ecto.NoResultsError` if the Set does not exist.

  ## Examples

      iex> get_set!(123)
      %Set{}

      iex> get_set!(456)
      ** (Ecto.NoResultsError)

  """
  def get_set!(id) do
    from(s in Set,
      left_join: p in assoc(s, :positions),
      order_by: p.inserted_at,
      preload: [positions: p]
    )
    |> Repo.get!(id)
  end

  @doc """
  Creates a set.

  ## Examples

      iex> create_set(%{field: value})
      {:ok, %Set{}}

      iex> create_set(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_set(attrs \\ %{}) do
    %Set{}
    |> Set.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a set.

  ## Examples

      iex> update_set(set, %{field: new_value})
      {:ok, %Set{}}

      iex> update_set(set, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_set(%Set{} = set, attrs) do
    set
    |> Set.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a set.

  ## Examples

      iex> delete_set(set)
      {:ok, %Set{}}

      iex> delete_set(set)
      {:error, %Ecto.Changeset{}}

  """
  def delete_set(%Set{} = set) do
    Repo.delete(set)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking set changes.

  ## Examples

      iex> change_set(set)
      %Ecto.Changeset{data: %Set{}}

  """
  def change_set(%Set{} = set, attrs \\ %{}) do
    Set.changeset(set, attrs)
  end

  def change_position(%Position{} = position, attrs \\ %{}) do
    Position.changeset(position, attrs)
  end

  def create_position(attrs \\ %{}) do
    %Position{}
    |> Position.changeset(attrs)
    |> Repo.insert()
  end

  def get_position!(id), do: Repo.get!(Position, id)

  def update_position(%Position{} = position, attrs) do
    position
    |> Position.changeset(attrs)
    |> Repo.update()
  end

  def format_to_play(%{to_play: "w"}, caps: false), do: "white"
  def format_to_play(_, caps: false), do: "black"
  def format_to_play(%{to_play: "w"}), do: "White"
  def format_to_play(_), do: "Black"

  def needs_solutions?(%{positions: positions}) do
    Enum.any?(positions, &is_nil(&1.solution_fen))
  end
end
