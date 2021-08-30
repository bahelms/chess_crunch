defmodule ChessCrunch.DrillsTest do
  use ChessCrunch.DataCase
  alias ChessCrunch.Drills

  describe "evaluate_moves/1 when there is no solution" do
    test "the answer is returned as correct" do
      assert {:correct, "sweet"} = Drills.evaluate_moves(nil, "sweet")
    end
  end

  describe "evaluate_moves/1 when move is correct" do
    test "the answer is returned as correct" do
      move = "1. e4 d4 2. g8"
      assert {:correct, ^move} = Drills.evaluate_moves("1. e4 d4 2. g8 b1", move)
    end
  end

  describe "evaluate_moves/1 when move is incorrect" do
    test "the answer is returned as incorrect" do
      move = "1. e4 d3"
      assert {:incorrect, ^move} = Drills.evaluate_moves("1. e4 d4 2. g8 b1", move)
    end
  end

  describe "evaluate_moves/1 when moves are exact match to solution" do
    test "the answer is returned as full_match" do
      move = "1. e4 d4 2. g8 b1"
      assert {:full_match, ^move} = Drills.evaluate_moves("1. e4 d4 2. g8 b1", move)
    end
  end

  describe "average_duration/1" do
    test "finds average of durations for given drills" do
      drills = [
        %{duration: 45},
        %{duration: 5},
        %{duration: 36},
        %{duration: 10},
        %{duration: 97}
      ]

      assert Drills.average_duration(drills) == 39
    end
  end
end
