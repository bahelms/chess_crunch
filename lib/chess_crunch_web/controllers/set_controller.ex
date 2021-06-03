defmodule ChessCrunchWeb.SetController do
  use ChessCrunchWeb, :controller

  alias ChessCrunch.Sets
  alias ChessCrunch.Sets.Set

  def index(conn, _params) do
    sets = Sets.list_sets(current_user(conn))
    render(conn, "index.html", sets: sets)
  end

  def new(conn, _params) do
    changeset = Sets.change_set(%Set{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"set" => set_params}) do
    set_params
    |> Map.put("user_id", current_user(conn).id)
    |> Sets.create_set()
    |> case do
      {:ok, set} ->
        conn
        |> put_flash(:info, "Set created successfully.")
        |> redirect(to: Routes.set_path(conn, :show, set))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    set = Sets.get_set!(id)
    render(conn, "show.html", set: set)
  end

  def edit(conn, %{"id" => id}) do
    set = Sets.get_set!(id)
    changeset = Sets.change_set(set)
    render(conn, "edit.html", set: set, changeset: changeset)
  end

  def update(conn, %{"id" => id, "set" => set_params}) do
    set = Sets.get_set!(id)

    case Sets.update_set(set, set_params) do
      {:ok, set} ->
        conn
        |> put_flash(:info, "Set updated successfully.")
        |> redirect(to: Routes.set_path(conn, :show, set))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", set: set, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    set = Sets.get_set!(id)
    {:ok, _set} = Sets.delete_set(set)

    conn
    |> put_flash(:info, "Set deleted successfully.")
    |> redirect(to: Routes.set_path(conn, :index))
  end

  defp current_user(conn) do
    conn.assigns[:current_user]
  end
end
