defmodule ChessCrunch.TimerTest do
  use ExUnit.Case
  alias ChessCrunch.Timer

  setup do
    {:ok, timer} = Timer.start_link(self())
    %{timer: timer}
  end

  test "timer starts at 0", %{timer: timer} do
    assert Timer.elapsed_seconds(timer) == 0
  end

  test "each second is sent to the given pid", %{timer: timer} do
    Timer.start(timer)
    :timer.sleep(2050)
    assert_received {:elapsed_seconds, 2}
  end

  test "start/0 begins an increment every second", %{timer: timer} do
    Timer.start(timer)
    :timer.sleep(2050)
    assert Timer.elapsed_seconds(timer) == 2
  end

  test "stop/0 stops timer and returns elapsed seconds", %{timer: timer} do
    Timer.start(timer)
    :timer.sleep(1050)
    assert Timer.stop(timer) == 1
  end

  test "stop/0 resets elapsed seconds to 0", %{timer: timer} do
    Timer.start(timer)
    :timer.sleep(1050)
    Timer.stop(timer)
    assert Timer.elapsed_seconds(timer) == 0
  end
end
