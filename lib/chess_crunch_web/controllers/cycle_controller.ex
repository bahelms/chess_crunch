defmodule ChessCrunchWeb.CycleController do
  use ChessCrunchWeb, :controller

  alias ChessCrunch.{Cycles, Sets}
  alias ChessCrunch.Cycles.Cycle

  def index(conn, _params) do
    %{completed: completed, in_progress: in_progress} =
      Cycles.list_cycles_grouped_by_status(conn.assigns[:current_user])

    render(conn, :index, completed_cycles: completed, in_progress_cycles: in_progress)
  end

  def new(conn, _params) do
    changeset = Cycles.change_set(%Cycle{})
    sets = Sets.list_sets(conn.assigns[:current_user])
    render(conn, "new.html", changeset: changeset, sets: sets)
  end

  def create(conn, %{"cycle" => cycle_params}) do
    cycle_params
    |> Map.put("user_id", conn.assigns[:current_user].id)
    |> parse_set_ids()
    |> Cycles.create_cycle()
    |> case do
      {:ok, _cycle} ->
        conn
        |> put_flash(:info, "Cycle created successfully.")
        |> redirect(to: Routes.cycle_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        sets = Sets.list_sets(conn.assigns[:current_user])
        render(conn, "new.html", changeset: changeset, sets: sets)
    end
  end

  def show(conn, %{"id" => id}) do
    cycle = Cycles.get_cycle(id) |> Cycles.load_rounds() |> Cycles.load_sets()
    render(conn, "show.html", cycle: cycle)
  end

  def delete(conn, %{"id" => id}) do
    cycle = Cycles.get_cycle(id)
    Cycles.delete_cycle!(cycle)

    conn
    |> put_flash(:info, "Cycle deleted successfully.")
    |> redirect(to: Routes.cycle_path(conn, :index))
  end

  defp parse_set_ids(params) do
    set_ids =
      params
      |> Map.keys()
      |> Enum.map(fn
        "set-" <> id -> id
        _ -> nil
      end)
      |> Enum.filter(&(!is_nil(&1)))

    Map.put(params, "set_ids", set_ids)
  end
end
