defmodule ChessCrunch.CyclesTest do
  use ChessCrunch.DataCase
  alias ChessCrunch.{Accounts, Cycles, Sets}
  alias ChessCrunch.Cycles.Cycle

  @valid_attrs %{"name" => "Test", "time_limit" => 360, "set_ids" => []}

  setup do
    {:ok, user} = Accounts.register_user(%{email: "bob@org.net", password: "123412341234"})
    {:ok, valid_attrs: Map.put(@valid_attrs, "user_id", user.id)}
  end

  describe "create_cycle/1" do
    test "with valid attrs creates a cycle", %{valid_attrs: attrs} do
      assert {:ok, %Cycle{} = cycle} = Cycles.create_cycle(attrs)
      assert cycle.name == "Test"
    end

    test "round is started at 1", %{valid_attrs: attrs} do
      {:ok, cycle} = Cycles.create_cycle(attrs)
      assert cycle.round == 1
    end

    test "given set IDs are associated", %{valid_attrs: attrs} do
      {:ok, set1} = Sets.create_set(%{name: "set1", user_id: attrs["user_id"]})
      {:ok, set2} = Sets.create_set(%{name: "set2", user_id: attrs["user_id"]})

      {:ok, cycle} =
        attrs
        |> Map.put("set_ids", [set1.id, set2.id])
        |> Cycles.create_cycle()

      cycle = Repo.preload(cycle, :sets)
      assert length(cycle.sets) == 2
    end
  end

  describe "positions_in_cycle/1" do
    test "returns the total number of positions for all sets in cycle", %{valid_attrs: attrs} do
      {:ok, set1} = Sets.create_set(%{name: "set1", user_id: attrs["user_id"]})
      {:ok, set2} = Sets.create_set(%{name: "set2", user_id: attrs["user_id"]})
      Sets.create_position(%{name: "1", set_id: set1.id, to_play: "white"})
      Sets.create_position(%{name: "2", set_id: set1.id, to_play: "white"})
      Sets.create_position(%{name: "1", set_id: set2.id, to_play: "white"})

      {:ok, cycle} =
        attrs
        |> Map.put("set_ids", [set1.id, set2.id])
        |> Cycles.create_cycle()

      assert Cycles.positions_in_cycle(cycle) == 3
    end
  end

  describe "total_completed_drills/1" do
    test "returns number of completed drills", %{valid_attrs: attrs} do
      {:ok, set1} = Sets.create_set(%{name: "set1", user_id: attrs["user_id"]})
      {:ok, pos1} = Sets.create_position(%{name: "1", set_id: set1.id, to_play: "white"})
      {:ok, cycle} = Cycles.create_cycle(attrs)

      Cycles.create_drill(%{position_id: pos1.id, cycle_id: cycle.id})
      Cycles.create_drill(%{position_id: pos1.id, cycle_id: cycle.id})

      Cycles.create_drill(%{
        position_id: pos1.id,
        cycle_id: cycle.id,
        completed_on: DateTime.utc_now()
      })

      assert Cycles.total_completed_drills(cycle) == 1
    end
  end
end
