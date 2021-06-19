defmodule ChessCrunchWeb.PositionController do
  use ChessCrunchWeb, :controller

  alias ChessCrunch.Sets
  alias ChessCrunch.Sets.Position

  def new(conn, %{"set_id" => set_id}) do
    changeset = Sets.change_position(%Position{})
    render(conn, "new.html", changeset: changeset, set_id: set_id)
  end

  def create(conn, %{"position" => position_params}) do
    case Sets.create_position(position_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Position created successfully.")
        |> redirect(to: Routes.set_path(conn, :show, position_params["set_id"]))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
