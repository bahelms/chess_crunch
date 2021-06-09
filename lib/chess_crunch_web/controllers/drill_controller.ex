defmodule ChessCrunchWeb.DrillController do
  use ChessCrunchWeb, :controller

  alias ChessCrunch.Drills
  alias ChessCrunch.Drills.Drill

  def new(conn, _params) do
    changeset = Drills.change_drill(%Drill{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"drill" => drill_params}) do
    case Drills.create_drill(drill_params) do
      {:ok, drill} ->
        conn
        |> put_flash(:info, "Drill created successfully.")
        |> redirect(to: Routes.drill_path(conn, :show, drill))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    drill = Drills.get_drill!(id)
    render(conn, "show.html", drill: drill)
  end

  def edit(conn, %{"id" => id}) do
    drill = Drills.get_drill!(id)
    changeset = Drills.change_drill(drill)
    render(conn, "edit.html", drill: drill, changeset: changeset)
  end

  def update(conn, %{"id" => id, "drill" => drill_params}) do
    drill = Drills.get_drill!(id)

    case Drills.update_drill(drill, drill_params) do
      {:ok, drill} ->
        conn
        |> put_flash(:info, "Drill updated successfully.")
        |> redirect(to: Routes.drill_path(conn, :show, drill))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", drill: drill, changeset: changeset)
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   drill = Drills.get_drill!(id)
  #   {:ok, _drill} = Drills.delete_drill(drill)

  #   conn
  #   |> put_flash(:info, "Drill deleted successfully.")
  #   |> redirect(to: Routes.drill_path(conn, :index))
  # end
end
