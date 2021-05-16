defmodule ChessCrunch.SetsTest do
  use ChessCrunch.DataCase

  alias ChessCrunch.Sets

  describe "sets" do
    alias ChessCrunch.Sets.Set

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def set_fixture(attrs \\ %{}) do
      {:ok, set} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sets.create_set()

      set
    end

    test "list_sets/0 returns all sets" do
      set = set_fixture()
      assert Sets.list_sets() == [set]
    end

    test "get_set!/1 returns the set with given id" do
      set = set_fixture()
      assert Sets.get_set!(set.id) == set
    end

    test "create_set/1 with valid data creates a set" do
      assert {:ok, %Set{} = set} = Sets.create_set(@valid_attrs)
      assert set.name == "some name"
    end

    test "create_set/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sets.create_set(@invalid_attrs)
    end

    test "update_set/2 with valid data updates the set" do
      set = set_fixture()
      assert {:ok, %Set{} = set} = Sets.update_set(set, @update_attrs)
      assert set.name == "some updated name"
    end

    test "update_set/2 with invalid data returns error changeset" do
      set = set_fixture()
      assert {:error, %Ecto.Changeset{}} = Sets.update_set(set, @invalid_attrs)
      assert set == Sets.get_set!(set.id)
    end

    test "delete_set/1 deletes the set" do
      set = set_fixture()
      assert {:ok, %Set{}} = Sets.delete_set(set)
      assert_raise Ecto.NoResultsError, fn -> Sets.get_set!(set.id) end
    end

    test "change_set/1 returns a set changeset" do
      set = set_fixture()
      assert %Ecto.Changeset{} = Sets.change_set(set)
    end
  end
end
