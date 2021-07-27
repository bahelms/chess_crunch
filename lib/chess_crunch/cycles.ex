defmodule ChessCrunch.Cycles do
  @moduledoc """
  The Cycles context.
  """

  import Ecto.Query, warn: false
  alias ChessCrunch.{Repo, Sets}
  alias ChessCrunch.Cycles.{Cycle, Round, Drill}

  def list_cycles(user) do
    Cycle
    |> where(user_id: ^user.id)
    |> Repo.all()
  end

  def list_cycles_grouped_by_status(user) do
    list_cycles(user)
    |> Repo.preload(drills: :position)
    |> Enum.reduce(%{completed: [], in_progress: []}, fn
      %{completed_on: nil} = cycle, map ->
        update_map_list(map, cycle, :in_progress)

      cycle, map ->
        update_map_list(map, cycle, :completed)
    end)
  end

  defp update_map_list(map, cycle, key) do
    {_, map} =
      Map.get_and_update(map, key, fn cycles ->
        {cycles, [cycle | cycles]}
      end)

    map
  end

  def change_set(cycle, attrs \\ %{})

  def change_set(%Cycle{} = cycle, attrs) do
    Cycle.changeset(cycle, attrs)
  end

  def change_set(%Round{} = round, attrs) do
    Round.changeset(round, attrs)
  end

  def create_cycle(%{"rounds" => _} = attrs) do
    %Cycle{}
    |> Cycle.changeset(attrs)
    |> associate_sets(attrs["set_ids"])
    |> Repo.insert()
  end

  def create_cycle(attrs) do
    attrs
    |> Map.put("rounds", [%{number: 1}])
    |> create_cycle()
  end

  def get_cycle(id), do: Repo.get!(Cycle, id)

  def get_round(id), do: Repo.get!(Round, id)

  def complete_round(round) do
    round
    |> change_set(%{completed_on: DateTime.utc_now()})
    |> Repo.update()

    # make next round cycle if 85% of drills were correct
  end

  defp associate_sets(changeset, set_ids) do
    sets = Sets.find_sets_by_ids(set_ids)
    Ecto.Changeset.put_assoc(changeset, :sets, sets)
  end

  def total_positions(cycle) do
    cycle
    |> Repo.preload(sets: :positions)
    |> Map.get(:sets)
    |> Enum.reduce(0, fn set, sum -> sum + length(set.positions) end)
  end

  def create_round(attrs) do
    %Round{}
    |> Round.changeset(attrs)
    |> Repo.insert!()
  end

  def create_drill(attrs) do
    %Drill{}
    |> Drill.changeset(attrs)
    |> Repo.insert!()
  end

  def create_drill(%Drill{} = drill, changes) do
    drill
    |> Drill.changeset(changes)
    |> Repo.insert!()
  end

  def total_drills(cycle) do
    Repo.preload(cycle, :drills).drills
    |> length()
  end

  def next_position(round_id) do
    from(r in Round,
      join: c in assoc(r, :cycle),
      join: s in assoc(c, :sets),
      join: p in assoc(s, :positions),
      left_join: d in assoc(r, :drills),
      on: d.position_id == p.id and d.round_id == ^round_id,
      select: p,
      where: r.id == ^round_id and is_nil(d.id),
      order_by: p.inserted_at
    )
    |> Repo.all()
    |> List.first()
  end

  def next_drill(round_id) when is_binary(round_id),
    do: next_drill(String.to_integer(round_id))

  def next_drill(round_id) do
    case next_position(round_id) do
      nil ->
        nil

      position ->
        %Drill{position_id: position.id, position: position, round_id: round_id}
    end
  end

  def complete_drill(drill, drill_params, round_id) do
    create_drill(drill, drill_params)

    case next_drill(round_id) do
      nil ->
        round_id
        |> get_round()
        |> complete_round()

        :round_completed

      drill ->
        {:next_drill, drill}
    end
  end

  def needs_solution?(%{drills: drills}) do
    Enum.any?(drills, &is_nil(&1.position.solution))
  end

  def current_round(rounds), do: Enum.find(rounds, &(!&1.completed_on))
end
