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
    case Cycles.complete_drill(assigns[:drill], drill_params, assigns[:cycle_id]) do
      :cycle_completed ->
        socket =
          socket
          |> put_flash(:info, "Cycle completed!")
          |> redirect(to: Routes.cycle_path(socket, :index))

        {:noreply, socket}

      {:next_drill, drill} ->
        {:noreply, assign(socket, drill: drill)}
    end
  end

  defp format_to_play(%{to_play: "white"}), do: "White"
  defp format_to_play(_), do: "Black"
end
