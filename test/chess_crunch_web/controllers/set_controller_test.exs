defmodule ChessCrunchWeb.SetControllerTest do
  use ChessCrunchWeb.ConnCase

  alias ChessCrunch.Sets

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:set) do
    {:ok, set} = Sets.create_set(@create_attrs)
    set
  end

  describe "index" do
    test "lists all sets", %{conn: conn} do
      conn = get(conn, Routes.set_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Sets"
    end
  end

  describe "new set" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.set_path(conn, :new))
      assert html_response(conn, 200) =~ "New Set"
    end
  end

  describe "create set" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.set_path(conn, :create), set: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.set_path(conn, :show, id)

      conn = get(conn, Routes.set_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Set"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.set_path(conn, :create), set: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Set"
    end
  end

  describe "edit set" do
    setup [:create_set]

    test "renders form for editing chosen set", %{conn: conn, set: set} do
      conn = get(conn, Routes.set_path(conn, :edit, set))
      assert html_response(conn, 200) =~ "Edit Set"
    end
  end

  describe "update set" do
    setup [:create_set]

    test "redirects when data is valid", %{conn: conn, set: set} do
      conn = put(conn, Routes.set_path(conn, :update, set), set: @update_attrs)
      assert redirected_to(conn) == Routes.set_path(conn, :show, set)

      conn = get(conn, Routes.set_path(conn, :show, set))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, set: set} do
      conn = put(conn, Routes.set_path(conn, :update, set), set: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Set"
    end
  end

  describe "delete set" do
    setup [:create_set]

    test "deletes chosen set", %{conn: conn, set: set} do
      conn = delete(conn, Routes.set_path(conn, :delete, set))
      assert redirected_to(conn) == Routes.set_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.set_path(conn, :show, set))
      end
    end
  end

  defp create_set(_) do
    set = fixture(:set)
    %{set: set}
  end
end
