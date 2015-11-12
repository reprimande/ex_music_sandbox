defmodule Clock do
  use GenServer

  def start(pid, func) do
    GenServer.cast(pid, {:start_timer, pid, func})
  end

  def stop(pid) do
    GenServer.cast(pid, {:stop_timer})
  end

  def _timer_interval(func) do
    func.()
  end

  def start_link(ms \\ 1000) do
    GenServer.start_link(__MODULE__, ms)
  end

  def init(ms) do
    {:ok, {ms}}
  end

  def handle_cast({:start_timer, pid, func}, {ms}) do
    :timer.apply_interval(ms, __MODULE__, :_timer_interval, [func])
    {:noreply, {ms}}
  end
end

