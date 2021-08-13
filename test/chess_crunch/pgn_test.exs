defmodule ChessCrunch.PGNTest do
  use ExUnit.Case
  alias ChessCrunch.PGN

  setup do
    pgn_string =
      "[SetUp \"1\"]\n[FEN \"rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 1\"]\n\n1. e3 Qb6 2. Bh2 axb3 3. d8"

    {:ok, %{pgn_string: pgn_string}}
  end

  describe "new/1" do
    test "moves are parsed into struct", %{pgn_string: pgn_string} do
      pgn = PGN.new(pgn_string)
      assert pgn.moves == "1. e3 Qb6 2. Bh2 axb3 3. d8"
    end

    test "fen is parsed into struct", %{pgn_string: pgn_string} do
      pgn = PGN.new(pgn_string)
      assert pgn.fen == "rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR w KQkq - 0 1"
    end

    test "to play is parsed into struct", %{pgn_string: pgn_string} do
      pgn = PGN.new(pgn_string)
      assert pgn.to_play == "w"
    end

    test "empty struct is returned for nil" do
      pgn = PGN.new(nil)
      refute pgn.moves
      refute pgn.fen
      refute pgn.to_play
    end
  end
end
