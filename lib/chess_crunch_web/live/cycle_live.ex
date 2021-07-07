defmodule ChessCrunchWeb.CycleLive do
  use ChessCrunchWeb, :live_view
  alias ChessCrunch.ImageStorage

  @impl true
  def mount(_params, _session, socket) do
    drill = %{
      position: %{to_play: "white", image_filename: "801359b8-d0fd-45a5-b081-75dddfda381c.jpg"}
    }

    {:ok, assign(socket, drill: drill)}
  end

  #   @impl true
  #   def handle_event("suggest", %{"q" => query}, socket) do
  #     {:noreply, assign(socket, results: search(query), query: query)}
  #   end

  defp format_to_play(%{to_play: "white"}), do: "White"
  defp format_to_play(_), do: "Black"
end
