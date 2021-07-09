defmodule ChessCrunch.CyclesTest do
  use ChessCrunch.DataCase
  alias ChessCrunch.{Accounts, Cycles, Sets}
  alias ChessCrunch.Cycles.Cycle

  @valid_attrs %{"name" => "Test", "time_limit" => 360, "set_ids" => []}

  setup do
    {:ok, user} = Accounts.register_user(%{email: "bob@org.net", password: "123412341234"})
    {:ok, valid_attrs: Map.put(@valid_attrs, "user_id", user.id)}
  end

  defp create_sets(user_id) do
    {:ok, set1} = Sets.create_set(%{name: "set1", user_id: user_id})
    {:ok, set2} = Sets.create_set(%{name: "set2", user_id: user_id})

    positions = [
      %{
        name: "100",
        to_play: "white",
        set_id: set1.id,
        inserted_at: NaiveDateTime.new!(2000, 1, 29, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 1, 29, 0, 0, 0)
      },
      %{
        name: "101",
        to_play: "black",
        set_id: set1.id,
        inserted_at: NaiveDateTime.new!(2000, 1, 30, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 1, 30, 0, 0, 0)
      },
      %{
        name: "102",
        to_play: "white",
        set_id: set1.id,
        inserted_at: NaiveDateTime.new!(2000, 1, 31, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 1, 31, 0, 0, 0)
      },
      %{
        name: "200",
        to_play: "black",
        set_id: set2.id,
        inserted_at: NaiveDateTime.new!(2000, 2, 1, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 2, 1, 0, 0, 0)
      },
      %{
        name: "201",
        to_play: "white",
        set_id: set2.id,
        inserted_at: NaiveDateTime.new!(2000, 2, 2, 0, 0, 0),
        updated_at: NaiveDateTime.new!(2000, 2, 2, 0, 0, 0)
      }
    ]

    Repo.insert_all(Sets.Position, positions)

    %{sets: [set1, set2], positions: positions}
  end

  defp create_cycle(attrs, set_ids) do
    {:ok, cycle} =
      attrs
      |> Map.put("set_ids", set_ids)
      |> Cycles.create_cycle()

    cycle
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

  describe "total_positions/1" do
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

      assert Cycles.total_positions(cycle) == 3
    end
  end

  describe "total_drills/1" do
    test "returns number of completed drills", %{valid_attrs: attrs} do
      {:ok, set1} = Sets.create_set(%{name: "set1", user_id: attrs["user_id"]})
      {:ok, pos1} = Sets.create_position(%{name: "1", set_id: set1.id, to_play: "white"})
      {:ok, cycle} = Cycles.create_cycle(attrs)

      Cycles.create_drill(%{position_id: pos1.id, cycle_id: cycle.id})
      Cycles.create_drill(%{position_id: pos1.id, cycle_id: cycle.id})
      Cycles.create_drill(%{position_id: pos1.id, cycle_id: cycle.id})

      assert Cycles.total_drills(cycle) == 3
    end
  end

  describe "next_position/1 with no drills" do
    test "returns the first ordered position that doesn't have a drill", %{
      valid_attrs: attrs
    } do
      %{sets: sets} = create_sets(attrs["user_id"])
      cycle = create_cycle(attrs, Enum.map(sets, & &1.id))

      position = Cycles.next_position(cycle.id)
      assert position.name == "100"
    end
  end

  describe "next_position/1 with first position having a drill" do
    test "returns the first ordered position that doesn't have a drill", %{
      valid_attrs: attrs
    } do
      %{sets: sets} = create_sets(attrs["user_id"])
      cycle = create_cycle(attrs, Enum.map(sets, & &1.id))
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos1.id})

      position = Cycles.next_position(cycle.id)
      assert position.name == "101"
    end
  end

  describe "next_position/1 with third position having a drill" do
    test "returns the first ordered position that doesn't have a drill", %{
      valid_attrs: attrs
    } do
      %{sets: sets} = create_sets(attrs["user_id"])
      cycle = create_cycle(attrs, Enum.map(sets, & &1.id))
      pos3 = Repo.get_by!(Sets.Position, name: "102")
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos3.id})

      position = Cycles.next_position(cycle.id)
      assert position.name == "100"
    end
  end

  describe "next_position/1 with first two positions having a drill" do
    test "returns the first ordered position that doesn't have a drill", %{
      valid_attrs: attrs
    } do
      %{sets: sets} = create_sets(attrs["user_id"])
      cycle = create_cycle(attrs, Enum.map(sets, & &1.id))
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      pos2 = Repo.get_by!(Sets.Position, name: "101")
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos1.id})
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos2.id})

      position = Cycles.next_position(cycle.id)
      assert position.name == "102"
    end
  end

  describe "next_position/1 with all positions having drills" do
    test "returns nil", %{valid_attrs: attrs} do
      %{sets: sets} = create_sets(attrs["user_id"])
      cycle = create_cycle(attrs, Enum.map(sets, & &1.id))
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      pos2 = Repo.get_by!(Sets.Position, name: "101")
      pos3 = Repo.get_by!(Sets.Position, name: "102")
      pos4 = Repo.get_by!(Sets.Position, name: "200")
      pos5 = Repo.get_by!(Sets.Position, name: "201")
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos1.id})
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos2.id})
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos3.id})
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos4.id})
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos5.id})

      refute Cycles.next_position(cycle.id)
    end
  end

  describe "next_drill/1" do
    test "returns a preloaded drill for the next position", %{valid_attrs: attrs} do
      %{sets: sets} = create_sets(attrs["user_id"])
      cycle = create_cycle(attrs, Enum.map(sets, & &1.id))
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos1.id})

      drill = Cycles.next_drill(cycle.id)
      pos2 = Repo.get_by!(Sets.Position, name: "101")
      assert drill.position_id == pos2.id
      assert drill.position.name == "101"
      assert drill.cycle_id == cycle.id
    end

    test "handles a string cycle_id", %{valid_attrs: attrs} do
      %{sets: sets} = create_sets(attrs["user_id"])
      cycle = create_cycle(attrs, Enum.map(sets, & &1.id))

      drill = Cycles.next_drill(Integer.to_string(cycle.id))
      assert drill.cycle_id == cycle.id
    end
  end

  describe "next_drill/1 when there is no next position" do
    test "returns nil", %{valid_attrs: attrs} do
      %{sets: sets} = create_sets(attrs["user_id"])
      cycle = create_cycle(attrs, Enum.map(sets, & &1.id))
      pos1 = Repo.get_by!(Sets.Position, name: "100")
      pos2 = Repo.get_by!(Sets.Position, name: "101")
      pos3 = Repo.get_by!(Sets.Position, name: "102")
      pos4 = Repo.get_by!(Sets.Position, name: "200")
      pos5 = Repo.get_by!(Sets.Position, name: "201")
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos1.id})
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos2.id})
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos3.id})
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos4.id})
      Cycles.create_drill(%{cycle_id: cycle.id, position_id: pos5.id})

      refute Cycles.next_drill(cycle.id)
    end
  end
end
