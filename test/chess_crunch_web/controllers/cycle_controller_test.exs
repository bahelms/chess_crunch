defmodule ChessCrunchWeb.CycleControllerTest do
  use ChessCrunchWeb.ConnCase
  alias ChessCrunch.{Repo, Sets, Accounts, Cycles}

  describe "create cycle" do
    test "parses set ids and associates them to the cycle", %{conn: conn} do
      {:ok, user} = Accounts.register_user(%{email: "bob@a.com", password: "123412341234"})
      {:ok, set1} = Sets.create_set(%{name: "set1", user_id: user.id})
      {:ok, set2} = Sets.create_set(%{name: "set2", user_id: user.id})

      attrs = %{
        "name" => "test",
        "time_limit" => 10,
        "round" => 1,
        "user_id" => user.id,
        "set-#{set1.id}" => "true",
        "set-#{set2.id}" => "true"
      }

      post(conn, Routes.cycle_path(conn, :create), cycle: attrs)

      cycle =
        Cycles.list_cycles(user)
        |> IO.inspect(label: "cycle")
        |> List.first()
        |> Repo.preload(:sets)

      assert length(cycle.sets) == 2
    end
  end
end
