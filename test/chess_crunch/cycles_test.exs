defmodule ChessCrunch.CyclesTest do
  use ChessCrunch.DataCase
  alias ChessCrunch.{Accounts, Cycles, Sets}
  alias ChessCrunch.Cycles.{Cycle}

  @valid_attrs %{"name" => "Test", "time_limit" => 360, "set_ids" => []}

  setup do
    {:ok, user} = Accounts.register_user(%{email: "bob@org.net", password: "123412341234"})
    {:ok, valid_attrs: Map.put(@valid_attrs, "user_id", user.id), user: user}
  end

  defp create_sets(user_id) do
    {:ok, set1} = Sets.create_set(%{name: "set1", user_id: user_id})
    {:ok, set2} = Sets.create_set(%{name: "set2", user_id: user_id})

    positions = [
      %{
        name: "100",
        to_play: "white",
        solution: "1. xx",
        set_id: set1.id,
        inserted_at: NaiveDateTime.new!(2000, 1, 29, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 1, 29, 0, 0, 0)
      },
      %{
        name: "101",
        to_play: "black",
        solution: "1. xx",
        set_id: set1.id,
        inserted_at: NaiveDateTime.new!(2000, 1, 30, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 1, 30, 0, 0, 0)
      },
      %{
        name: "102",
        to_play: "white",
        solution: "1. xx",
        set_id: set1.id,
        inserted_at: NaiveDateTime.new!(2000, 1, 31, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 1, 31, 0, 0, 0)
      },
      %{
        name: "200",
        to_play: "black",
        solution: "1. xx",
        set_id: set2.id,
        inserted_at: NaiveDateTime.new!(2000, 2, 1, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 2, 1, 0, 0, 0)
      },
      %{
        name: "201",
        to_play: "white",
        solution: "1. xx",
        set_id: set2.id,
        inserted_at: NaiveDateTime.new!(2000, 2, 2, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 2, 2, 0, 0, 0)
      }
    ]

    Repo.insert_all(Sets.Position, positions)

    %{sets: [set1, set2]}
  end

  defp create_cycle(attrs, set_ids) do
    {:ok, cycle} =
      attrs
      |> Map.put("set_ids", set_ids)
      |> Cycles.create_cycle()

    cycle
  end

  defp create_cycle_with_sets(%{valid_attrs: attrs} = context) do
    %{sets: sets} = create_sets(attrs["user_id"])
    cycle = create_cycle(attrs, Enum.map(sets, & &1.id))
    [round | _] = Repo.preload(cycle, :rounds).rounds
    Map.merge(context, %{cycle: cycle, round: round, sets: sets})
  end

  defp no_more_drills(%{valid_attrs: attrs}) do
    {:ok, set} = Sets.create_set(%{name: "set1", user_id: attrs["user_id"]})
    Sets.create_position(%{name: "1", to_play: "black", set_id: set.id, solution: "1. xx"})
    cycle = create_cycle(attrs, [set.id])
    round = Cycles.create_round(%{cycle_id: cycle.id, number: 1, time_limit: 360})
    %{round: round}
  end

  defp create_passing_drills(%{round: round} = context) do
    pos1 = Repo.get_by!(Sets.Position, name: "100")
    pos2 = Repo.get_by!(Sets.Position, name: "101")
    pos3 = Repo.get_by!(Sets.Position, name: "102")
    pos4 = Repo.get_by!(Sets.Position, name: "200")
    pos5 = Repo.get_by!(Sets.Position, name: "201")
    Cycles.create_drill(%{round_id: round.id, position_id: pos1.id, answer: pos1.solution})
    Cycles.create_drill(%{round_id: round.id, position_id: pos2.id, answer: pos1.solution})
    Cycles.create_drill(%{round_id: round.id, position_id: pos3.id, answer: pos1.solution})
    Cycles.create_drill(%{round_id: round.id, position_id: pos4.id, answer: pos1.solution})
    Cycles.create_drill(%{round_id: round.id, position_id: pos5.id, answer: pos1.solution})
    context
  end

  describe "create_cycle/1" do
    setup [:create_cycle_with_sets]

    test "with valid attrs creates a cycle", %{valid_attrs: attrs} do
      assert {:ok, %Cycle{} = cycle} = Cycles.create_cycle(attrs)
      assert cycle.name == "Test"
    end

    test "given set IDs are associated", %{cycle: cycle} do
      assert length(Repo.preload(cycle, :sets).sets) == 2
    end

    test "the first round is created", %{cycle: cycle} do
      [round | _] = rounds = Repo.preload(cycle, :rounds).rounds
      assert length(rounds) == 1
      assert round.number == 1
      assert round.cycle_id == cycle.id
    end
  end

  describe "total_positions/1" do
    setup [:create_cycle_with_sets]

    test "returns the total number of positions for all sets in cycle", %{cycle: cycle} do
      assert Cycles.total_positions(cycle) == 5
    end
  end

  describe "total_drills/1" do
    setup [:create_cycle_with_sets]

    test "returns number of completed drills", %{valid_attrs: attrs} do
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      {:ok, cycle} = Cycles.create_cycle(attrs)
      [round | _] = Repo.preload(cycle, :rounds).rounds

      Cycles.create_drill(%{position_id: pos1.id, round_id: round.id})
      Cycles.create_drill(%{position_id: pos1.id, round_id: round.id})
      Cycles.create_drill(%{position_id: pos1.id, round_id: round.id})

      assert Cycles.total_drills(cycle) == 3
    end
  end

  describe "next_position/1 with no drills" do
    setup [:create_cycle_with_sets]

    test "returns the first ordered position that doesn't have a drill", %{round: round} do
      position = Cycles.next_position(round.id)
      assert position.name == "100"
    end
  end

  describe "next_position/1 with first position having a drill" do
    setup [:create_cycle_with_sets]

    test "returns the first ordered position that doesn't have a drill", %{round: round} do
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      Cycles.create_drill(%{round_id: round.id, position_id: pos1.id})

      position = Cycles.next_position(round.id)
      assert position.name == "101"
    end
  end

  describe "next_position/1 with third position having a drill" do
    setup [:create_cycle_with_sets]

    test "returns the first ordered position that doesn't have a drill", %{round: round} do
      pos3 = Repo.get_by!(Sets.Position, name: "102")
      Cycles.create_drill(%{round_id: round.id, position_id: pos3.id})

      position = Cycles.next_position(round.id)
      assert position.name == "100"
    end
  end

  describe "next_position/1 with first two positions having a drill" do
    setup [:create_cycle_with_sets]

    test "returns the first ordered position that doesn't have a drill", %{round: round} do
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      pos2 = Repo.get_by!(Sets.Position, name: "101")
      Cycles.create_drill(%{round_id: round.id, position_id: pos1.id})
      Cycles.create_drill(%{round_id: round.id, position_id: pos2.id})

      position = Cycles.next_position(round.id)
      assert position.name == "102"
    end
  end

  describe "next_position/1 with all positions having drills" do
    setup [:create_cycle_with_sets, :create_passing_drills]

    test "returns nil", %{round: round} do
      refute Cycles.next_position(round.id)
    end
  end

  describe "next_position/1 with multiple cycles using the same sets" do
    setup [:create_cycle_with_sets]

    test "returns the first ordered position that doesn't have a drill", %{
      round: round1,
      sets: sets,
      valid_attrs: attrs
    } do
      cycle2 = create_cycle(attrs, Enum.map(sets, & &1.id))
      round2 = Cycles.create_round(%{cycle_id: cycle2.id, number: 1, time_limit: 360})
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      pos2 = Repo.get_by!(Sets.Position, name: "101")
      pos3 = Repo.get_by!(Sets.Position, name: "102")

      Cycles.create_drill(%{round_id: round1.id, position_id: pos1.id})
      Cycles.create_drill(%{round_id: round1.id, position_id: pos2.id})
      Cycles.create_drill(%{round_id: round1.id, position_id: pos3.id})

      next_pos = Cycles.next_position(round2.id)
      assert next_pos.name == "100"
    end
  end

  describe "next_drill/1" do
    setup [:create_cycle_with_sets]

    test "returns a preloaded drill for the next position", %{round: round} do
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      Cycles.create_drill(%{round_id: round.id, position_id: pos1.id})

      drill = Cycles.next_drill(round.id)
      pos2 = Repo.get_by!(Sets.Position, name: "101")
      assert drill.position_id == pos2.id
      assert drill.position.name == "101"
      assert drill.round_id == round.id
    end

    test "handles a string round_id", %{round: round} do
      drill = Cycles.next_drill(Integer.to_string(round.id))
      assert drill.round_id == round.id
    end
  end

  describe "next_drill/1 when there is no next position" do
    setup [:create_cycle_with_sets]

    test "returns nil", %{round: round} do
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      pos2 = Repo.get_by!(Sets.Position, name: "101")
      pos3 = Repo.get_by!(Sets.Position, name: "102")
      pos4 = Repo.get_by!(Sets.Position, name: "200")
      pos5 = Repo.get_by!(Sets.Position, name: "201")
      Cycles.create_drill(%{round_id: round.id, position_id: pos1.id})
      Cycles.create_drill(%{round_id: round.id, position_id: pos2.id})
      Cycles.create_drill(%{round_id: round.id, position_id: pos3.id})
      Cycles.create_drill(%{round_id: round.id, position_id: pos4.id})
      Cycles.create_drill(%{round_id: round.id, position_id: pos5.id})

      refute Cycles.next_drill(round.id)
    end
  end

  describe "complete_drill/3" do
    setup [:create_cycle_with_sets]

    test "creates a drill record", %{round: round} do
      drill = Cycles.next_drill(round.id)
      params = %{"answer" => "garbage", "duration" => "20"}

      Cycles.complete_drill(drill, params, round.id)
      assert Cycles.total_drills(round) == 1
    end

    test "returns the next drill if there is one", %{round: round} do
      drill = Cycles.next_drill(round.id)
      params = %{"answer" => "garbage", "duration" => "20"}

      assert {:next_drill, drill} = Cycles.complete_drill(drill, params, round.id)
      assert Repo.preload(drill, :position).position.name == "101"
    end
  end

  describe "complete_drill/3 with no more drills" do
    setup [:no_more_drills]

    test "completes the round", %{round: round} do
      drill = Cycles.next_drill(round.id)
      params = %{"answer" => "garbage", "duration" => "20"}

      assert {:round_completed, round, _} = Cycles.complete_drill(drill, params, round.id)
      assert round.completed_on
    end
  end

  describe "list_cycles_grouped_by_status/1" do
    test "returns completed and in progress", %{valid_attrs: attrs, user: user} do
      completed_attrs = Map.put(attrs, "completed_on", DateTime.utc_now())
      Cycles.create_cycle(attrs)
      Cycles.create_cycle(attrs)
      Cycles.create_cycle(attrs)
      Cycles.create_cycle(completed_attrs)
      Cycles.create_cycle(completed_attrs)

      %{completed: completed, in_progress: in_progress} =
        Cycles.list_cycles_grouped_by_status(user)

      assert length(completed) == 2
      assert length(in_progress) == 3
    end

    test "returns only completed", %{valid_attrs: attrs, user: user} do
      completed_attrs = Map.put(attrs, "completed_on", DateTime.utc_now())
      Cycles.create_cycle(completed_attrs)
      Cycles.create_cycle(completed_attrs)

      %{completed: completed, in_progress: in_progress} =
        Cycles.list_cycles_grouped_by_status(user)

      assert length(completed) == 2
      assert length(in_progress) == 0
    end
  end

  describe "list_cycles_grouped_by_status/1 with sets" do
    setup [:create_cycle_with_sets]

    test "preloads drills and their positions", %{round: round, user: user} do
      pos = Repo.get_by!(Sets.Position, name: "201")
      Cycles.create_drill(%{round_id: round.id, position_id: pos.id})
      %{in_progress: in_progress} = Cycles.list_cycles_grouped_by_status(user)

      [drill | _] = List.first(in_progress).drills
      assert drill.position.name == "201"
    end
  end

  describe "needs_solutions?/1" do
    test "returns true when a position does not have a solution" do
      assert %{
               drills: [
                 %{position: %{solution: "hey"}},
                 %{position: %{solution: nil}},
                 %{position: %{solution: "there"}}
               ]
             }
             |> Cycles.needs_solutions?()
    end

    test "returns false when all positions have solutions" do
      refute %{
               drills: [
                 %{position: %{solution: "hey"}},
                 %{position: %{solution: "there"}}
               ]
             }
             |> Cycles.needs_solutions?()
    end

    test "returns false with no drills" do
      refute Cycles.needs_solutions?(%{drills: []})
    end
  end

  describe "current_round/1" do
    test "returns the latest incomplete round" do
      round =
        [
          %{id: 1, number: 1, completed_on: DateTime.utc_now()},
          %{id: 2, number: 2, completed_on: DateTime.utc_now()},
          %{id: 3, number: 3, completed_on: DateTime.utc_now()},
          %{id: 4, number: 3, completed_on: nil}
        ]
        |> Cycles.current_round()

      assert round.id == 4
    end

    test "returns nil when all rounds are complete" do
      round =
        [
          %{id: 1, number: 1, completed_on: DateTime.utc_now()},
          %{id: 2, number: 2, completed_on: DateTime.utc_now()},
          %{id: 3, number: 3, completed_on: DateTime.utc_now()}
        ]
        |> Cycles.current_round()

      refute round
    end
  end

  describe "complete_round/1" do
    setup [:create_cycle_with_sets, :create_passing_drills]

    test "sets the completed_on time", %{round: round} do
      assert {:round_completed, round, _} = Cycles.complete_round(round)
      assert round.completed_on
    end

    test "creates the next round", %{round: round} do
      assert {:round_completed, _, round} = Cycles.complete_round(round)
      assert round.number == 2
      assert round.time_limit == 180
    end
  end

  describe "complete_round/1 when positions don't have solutions" do
    setup [:create_cycle_with_sets]

    test "returns needs_solutions and does not set completed_on", %{round: round} do
      Repo.update_all(Sets.Position, set: [solution: nil])
      pos = Repo.get_by!(Sets.Position, name: "201")
      Cycles.create_drill(%{position_id: pos.id, round_id: round.id})

      assert {:needs_solutions, round} = Cycles.complete_round(round)
      refute round.completed_on
    end
  end

  describe "complete_round/1 when accuracy is < 85%" do
    setup [:create_cycle_with_sets]

    test "sets the completed_on time", %{round: round} do
      pos = Repo.get_by!(Sets.Position, name: "201")
      Cycles.create_drill(%{position_id: pos.id, round_id: round.id})

      assert {:round_completed, round, _} = Cycles.complete_round(round)
      assert round.completed_on
    end

    test "creates a new record for the same round", %{round: round} do
      pos = Repo.get_by!(Sets.Position, name: "201")
      Cycles.create_drill(%{position_id: pos.id, round_id: round.id})

      assert {:round_completed, round, next_round} = Cycles.complete_round(round)
      assert next_round.number == 1
      assert next_round.time_limit == 360
      assert next_round.id != round.id
    end
  end

  @tag :skip
  describe "complete_round/1 with no more rounds" do
    setup [:create_cycle_with_sets, :create_passing_drills]

    test "completes the cycle", %{round: round} do
      round = Map.put(round, :time_limit, 10)
      assert {:cycle_completed, round} = Cycles.complete_round(round)
      assert Cycles.get_cycle(round.cycle_id).completed_on
    end
  end
end
