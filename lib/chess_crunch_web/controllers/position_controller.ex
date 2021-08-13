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

  def edit(conn, %{"id" => id}) do
    # TODO: this needs to be tied to a user
    position = Sets.get_position!(id)
    changeset = Sets.change_position(position)
    render(conn, :edit, changeset: changeset, position: position)
  end

  def update(conn, %{"id" => id, "position" => position_params}) do
    position = Sets.get_position!(id)

    case Sets.update_position(position, position_params) do
      {:ok, position} ->
        conn
        |> put_flash(:info, "Position updated successfully.")
        |> redirect(to: Routes.set_path(conn, :show, position.set_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, changeset: changeset)
    end
  end

  defp add_full_fen(%{"fen" => fen, "to_play" => to_play} = position_params) do
    Map.put(position_params, "fen", "#{fen} #{to_play} KQkq - 0 1")
  end
end
