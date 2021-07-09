defmodule ChessCrunchWeb.CycleLive do
  use ChessCrunchWeb, :live_view
  alias ChessCrunch.{Cycles, ImageStorage}

  @impl true
  def mount(%{"id" => cycle_id}, _session, socket) do
    drill = Cycles.next_drill(cycle_id)
    {:ok, assign(socket, drill: drill, cycle_id: String.to_integer(cycle_id))}
  end

  @impl true
  def handle_event("save_answer", %{"drill" => drill_params}, %{assigns: assigns} = socket) do
    Cycles.create_drill(assigns[:drill], drill_params)

    case Cycles.next_drill(assigns[:cycle_id]) do
      nil ->
        assigns[:cycle_id]
        |> Cycles.get_cycle()
        |> Cycles.complete_cycle()

        # make next round cycle

        socket =
          socket
          |> put_flash(:info, "Cycle completed!")
          |> redirect(to: Routes.cycle_path(socket, :index))

        {:noreply, socket}

      drill ->
        {:noreply, assign(socket, drill: drill)}
    end
  end

  defp format_to_play(%{to_play: "white"}), do: "White"
  defp format_to_play(_), do: "Black"
end
