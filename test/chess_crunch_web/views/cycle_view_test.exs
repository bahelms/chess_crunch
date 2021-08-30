defmodule ChessCrunchWeb.CycleViewTest do
  use ExUnit.Case
  alias ChessCrunchWeb.CycleView

  describe "average_duration/1" do
    test "less than a minute has leading zero" do
      drills = [%{duration: 42}]
      assert CycleView.average_duration(drills) == "0:42"
    end

    test "more than a minute rolls over at 60" do
      drills = [%{duration: 61}]
      assert CycleView.average_duration(drills) == "1:01"

      drills = [%{duration: 131}]
      assert CycleView.average_duration(drills) == "2:11"
    end

    test "60 seconds is a minute" do
      drills = [%{duration: 60}]
      assert CycleView.average_duration(drills) == "1:00"
    end
  end
end
