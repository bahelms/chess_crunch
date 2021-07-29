defmodule ChessCrunchWeb.SetControllerTest do
  use ChessCrunchWeb.ConnCase

  alias ChessCrunch.Sets

  @create_attrs %{name: "some name"}
  @invalid_attrs %{name: nil}

  setup :register_and_log_in_user

  defp create_set(%{user: user} = context) do
    {:ok, set} = Sets.create_set(Map.put(@create_attrs, :user_id, user.id))
    Map.put(context, :set, set)
  end

  describe "create set" do
    setup [:register_and_log_in_user]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.set_path(conn, :create), set: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.set_path(conn, :show, id)

      conn = get(conn, Routes.set_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Set created successfully"
    end

    test "rerenders form when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.set_path(conn, :create), set: @invalid_attrs)
      assert html_response(conn, 200) =~ "Create a new set"
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
end
