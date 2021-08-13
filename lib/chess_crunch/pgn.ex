defmodule ChessCrunch.PGN do
  defstruct [:moves, :fen, :to_play]

  def new(nil), do: %__MODULE__{}

  def new(pgn_string) do
    [pgn | [moves | _]] = String.split(pgn_string, "\n\n")
    [_ | [fen | _]] = Regex.run(~r/\[FEN "(.+)"\]/, pgn)
    [_ | [to_play | _]] = String.split(fen)
    %__MODULE__{moves: moves, fen: fen, to_play: to_play}
  end
end
