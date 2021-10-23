defmodule ChessCrunchWeb.PositionController do
  use ChessCrunchWeb, :controller

  alias ChessCrunch.Sets
  alias ChessCrunch.Sets.Position

  def new(conn, %{"set_id" => set_id}) do
    changeset = Sets.change_position(%Position{})
    render(conn, "new.html", changeset: changeset, set_id: set_id)
  end

  def create(conn, %{"position" => position_params}) do
    position_params
    |> add_full_fen()
    |> Sets.create_position()
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Position created successfully.")
        |> redirect(to: Routes.set_path(conn, :show, position_params["set_id"]))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, set_id: position_params["set_id"])
    end
  end

  def delete(conn, %{"id" => id}) do
    position = Sets.get_position!(id)
    Sets.delete_position!(position)

    conn
    |> put_flash(:info, "Position deleted successfully.")
    |> redirect(to: Routes.set_path(conn, :show, position.set_id))
  end

  defp add_full_fen(%{"fen" => fen, "to_play" => to_play} = position_params) do
    Map.put(position_params, "fen", "#{fen} #{to_play} KQkq - 0 1")
  end
end
