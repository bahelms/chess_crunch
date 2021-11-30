defmodule ChessCrunch.Timer do
  use GenServer

  @one_second 1_000
  @initial_seconds 0

  def start_link(caller) do
    GenServer.start_link(__MODULE__, %{seconds: @initial_seconds, caller: caller})
  end

  def elapsed_seconds(timer) do
    GenServer.call(timer, :elapsed_seconds)
  end

  def start(timer) do
    GenServer.cast(timer, :start)
  end

  def stop(timer) do
    GenServer.call(timer, :stop)
  end

  @impl true
  def init(state) do
    {:ok, Map.put(state, :running, false)}
  end

  @impl true
  def handle_call(:elapsed_seconds, _, %{seconds: seconds} = state) do
    {:reply, seconds, state}
  end

  @impl true
  def handle_call(:stop, _, %{seconds: seconds, timer_ref: timer_ref} = state) do
    Process.cancel_timer(timer_ref)
    state = Map.merge(state, %{running: false, seconds: @initial_seconds})
    {:reply, seconds, state}
  end

  @impl true
  def handle_cast(:start, state) do
    {:noreply, Map.merge(state, %{running: true, timer_ref: next_tick()})}
  end

  @impl true
  def handle_info(:tick, %{running: false} = state), do: {:noreply, state}

  @impl true
  def handle_info(:tick, %{seconds: seconds, caller: caller} = state) do
    seconds = seconds + 1
    report_seconds(caller, seconds)
    {:noreply, Map.merge(state, %{seconds: seconds, timer_ref: next_tick()})}
  end

  defp next_tick do
    Process.send_after(self(), :tick, @one_second)
  end

  defp report_seconds(pid, seconds) do
    send(pid, {:elapsed_seconds, seconds})
  end
end
