defmodule ChessCrunch.Cycles do
  @moduledoc """
  The Cycles context.
  """

  @accuracy_threshold 0.85

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
    |> Repo.preload(rounds: [:cycle, drills: :position])
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

  def create_cycle(%{"time_limit" => time_limit} = attrs) do
    attrs
    |> Map.put("rounds", [%{number: 1, time_limit: time_limit}])
    |> create_cycle()
  end

  def order_by_completion(cycles) do
    Enum.sort_by(cycles, & &1.completed_on, {:desc, Date})
  end

  def get_cycle(id), do: Repo.get!(Cycle, id)

  def get_round(id), do: Repo.get!(Round, id)

  def complete_round(round) do
    round = Repo.preload(round, drills: :position)

    case needs_solutions?(round) do
      true ->
        {:needs_solutions, round}

      false ->
        {:ok, round} =
          round
          |> change_set(%{completed_on: DateTime.utc_now()})
          |> Repo.update()

        case accuracy_percent(round.drills) do
          percent when percent < @accuracy_threshold ->
            next_round =
              create_round(%{
                number: round.number,
                time_limit: round.time_limit,
                cycle_id: round.cycle_id
              })

            {:round_completed, round, next_round}

          _percent ->
            case next_time_limit(round) do
              nil ->
                complete_cycle(round)
                {:cycle_completed, round}

              limit ->
                next_round =
                  create_round(%{
                    number: round.number + 1,
                    time_limit: limit,
                    cycle_id: round.cycle_id
                  })

                {:round_completed, round, next_round}
            end
        end
    end
  end

  # TODO: putting result on drill table will optimize this away
  def accuracy_percent(drills) do
    correct =
      Enum.reduce(drills, 0, fn drill, sum ->
        if drill.answer == drill.position.solution_moves do
          sum + 1
        else
          sum
        end
      end)

    correct / length(drills)
  end

  def next_time_limit(%{time_limit: 360}), do: 180
  def next_time_limit(%{time_limit: 180}), do: 90
  def next_time_limit(%{time_limit: 90}), do: 45
  def next_time_limit(%{time_limit: 45}), do: 25
  def next_time_limit(%{time_limit: 25}), do: 15
  def next_time_limit(%{time_limit: 15}), do: 10
  def next_time_limit(%{time_limit: 10}), do: nil
  def next_time_limit(_), do: 0

  def complete_cycle(round) do
    Repo.preload(round, :cycle).cycle
    |> change_set(%{completed_on: DateTime.utc_now()})
    |> Repo.update()
  end

  defp associate_sets(changeset, set_ids) do
    sets = Sets.find_sets_by_ids(set_ids)
    Ecto.Changeset.put_assoc(changeset, :sets, sets)
  end

  def total_positions(cycle) do
    cycle
    |> Repo.preload(sets: :positions)
    |> Map.get(:sets)
    |> Enum.reduce(0, &(&2 + length(&1.positions)))
  end

  def create_round(attrs) do
    %Round{}
    |> Round.changeset(attrs)
    |> Repo.insert!()
  end

  def total_drills(model) do
    Repo.preload(model, :drills).drills
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

  def complete_drill(drill) do
    case next_drill(drill.round_id) do
      nil ->
        drill.round_id
        |> get_round()
        |> complete_round()

      drill ->
        {:next_drill, drill}
    end
  end

  def needs_solutions?(%{drills: drills}) do
    Enum.any?(drills, &is_nil(&1.position.solution_fen))
  end

  def in_progress?(cycle) do
    total_drills(cycle) != total_positions(cycle)
  end

  def current_round(rounds), do: Enum.find(rounds, &(!&1.completed_on))

  def current_round_for_cycle(cycle_id) do
    cycle =
      cycle_id
      |> get_cycle()
      |> Repo.preload(:rounds)

    current_round(cycle.rounds)
  end
end
