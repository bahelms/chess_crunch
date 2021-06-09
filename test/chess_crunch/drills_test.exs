defmodule ChessCrunch.DrillsTest do
  use ChessCrunch.DataCase

  alias ChessCrunch.Drills

  describe "drills" do
    alias ChessCrunch.Drills.Drill

    @valid_attrs %{fen: "some fen", solution: "some solution"}
    @update_attrs %{fen: "some updated fen", solution: "some updated solution"}
    @invalid_attrs %{fen: nil, solution: nil}

    def drill_fixture(attrs \\ %{}) do
      {:ok, drill} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Drills.create_drill()

      drill
    end

    test "list_drills/0 returns all drills" do
      drill = drill_fixture()
      assert Drills.list_drills() == [drill]
    end

    test "get_drill!/1 returns the drill with given id" do
      drill = drill_fixture()
      assert Drills.get_drill!(drill.id) == drill
    end

    test "create_drill/1 with valid data creates a drill" do
      assert {:ok, %Drill{} = drill} = Drills.create_drill(@valid_attrs)
      assert drill.fen == "some fen"
      assert drill.solution == "some solution"
    end

    test "create_drill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Drills.create_drill(@invalid_attrs)
    end

    test "update_drill/2 with valid data updates the drill" do
      drill = drill_fixture()
      assert {:ok, %Drill{} = drill} = Drills.update_drill(drill, @update_attrs)
      assert drill.fen == "some updated fen"
      assert drill.solution == "some updated solution"
    end

    test "update_drill/2 with invalid data returns error changeset" do
      drill = drill_fixture()
      assert {:error, %Ecto.Changeset{}} = Drills.update_drill(drill, @invalid_attrs)
      assert drill == Drills.get_drill!(drill.id)
    end

    test "delete_drill/1 deletes the drill" do
      drill = drill_fixture()
      assert {:ok, %Drill{}} = Drills.delete_drill(drill)
      assert_raise Ecto.NoResultsError, fn -> Drills.get_drill!(drill.id) end
    end

    test "change_drill/1 returns a drill changeset" do
      drill = drill_fixture()
      assert %Ecto.Changeset{} = Drills.change_drill(drill)
    end
  end
end
