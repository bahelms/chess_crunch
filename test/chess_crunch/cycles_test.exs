defmodule ChessCrunch.CyclesTest do
  use ChessCrunch.DataCase
  alias ChessCrunch.Cycles
  alias ChessCrunch.{Accounts, Cycles.Cycle, Sets}

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
end
