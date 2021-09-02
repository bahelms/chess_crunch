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

  describe "accuracy_percent/1" do
    test "returns 0 when given no drills" do
      assert Drills.accuracy_percent([]) == 0
    end

    test "returns percentage of correct drills" do
      percent =
        [
          %{answer: "aaa", position: %{solution_moves: "aaa"}},
          %{answer: "aab", position: %{solution_moves: "aab"}},
          %{answer: "aab", position: %{solution_moves: "xaa"}},
          %{answer: "abb", position: %{solution_moves: "abb"}},
          %{answer: "bbb", position: %{solution_moves: "bbb"}}
        ]
        |> Drills.accuracy_percent()

      assert percent == 80.0
    end
  end

  describe "accuracy_counts/1" do
    test "returns zero counts when given no drills" do
      assert Drills.accuracy_counts([]) == %{correct: 0, incorrect: 0}
    end

    test "sums the number of correct and incorrect drills" do
      counts =
        [
          %{answer: "aaa", position: %{solution_moves: "aaa"}},
          %{answer: "aab", position: %{solution_moves: "aab"}},
          %{answer: "aab", position: %{solution_moves: "xaa"}},
          %{answer: "aba", position: %{solution_moves: "xax"}},
          %{answer: "abb", position: %{solution_moves: "abb"}},
          %{answer: "bbb", position: %{solution_moves: "bbb"}}
        ]
        |> Drills.accuracy_counts()

      assert counts.correct == 4
      assert counts.incorrect == 2
    end

    test "correct is set to zero when all drills are wrong" do
      counts =
        [%{answer: "aaa", position: %{solution_moves: "nope"}}]
        |> Drills.accuracy_counts()

      assert counts.correct == 0
      assert counts.incorrect == 1
    end
  end
end
