defmodule ChessCrunchWeb.DrillControllerTest do
  use ChessCrunchWeb.ConnCase

  alias ChessCrunch.Drills

  @create_attrs %{fen: "some fen", solution: "some solution"}
  @update_attrs %{fen: "some updated fen", solution: "some updated solution"}
  @invalid_attrs %{fen: nil, solution: nil}

  def fixture(:drill) do
    {:ok, drill} = Drills.create_drill(@create_attrs)
    drill
  end

  describe "index" do
    test "lists all drills", %{conn: conn} do
      conn = get(conn, Routes.drill_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Drills"
    end
  end

  describe "new drill" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.drill_path(conn, :new))
      assert html_response(conn, 200) =~ "New Drill"
    end
  end

  describe "create drill" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.drill_path(conn, :create), drill: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.drill_path(conn, :show, id)

      conn = get(conn, Routes.drill_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Drill"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.drill_path(conn, :create), drill: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Drill"
    end
  end

  describe "edit drill" do
    setup [:create_drill]

    test "renders form for editing chosen drill", %{conn: conn, drill: drill} do
      conn = get(conn, Routes.drill_path(conn, :edit, drill))
      assert html_response(conn, 200) =~ "Edit Drill"
    end
  end

  describe "update drill" do
    setup [:create_drill]

    test "redirects when data is valid", %{conn: conn, drill: drill} do
      conn = put(conn, Routes.drill_path(conn, :update, drill), drill: @update_attrs)
      assert redirected_to(conn) == Routes.drill_path(conn, :show, drill)

      conn = get(conn, Routes.drill_path(conn, :show, drill))
      assert html_response(conn, 200) =~ "some updated fen"
    end

    test "renders errors when data is invalid", %{conn: conn, drill: drill} do
      conn = put(conn, Routes.drill_path(conn, :update, drill), drill: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Drill"
    end
  end

  describe "delete drill" do
    setup [:create_drill]

    test "deletes chosen drill", %{conn: conn, drill: drill} do
      conn = delete(conn, Routes.drill_path(conn, :delete, drill))
      assert redirected_to(conn) == Routes.drill_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.drill_path(conn, :show, drill))
      end
    end
  end

  defp create_drill(_) do
    drill = fixture(:drill)
    %{drill: drill}
  end
end
