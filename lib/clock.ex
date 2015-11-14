defmodule Clock do
  use GenServer

  def start(pid) do
    GenServer.cast(pid, {:start_timer})
  end

  def stop(pid) do
    GenServer.cast(pid, {:stop_timer})
  end

  def add_tick_handler(pid, listener) do
    GenServer.cast(pid, {:add_tick_handler, listener})
  end

  def _timer_interval(event) do
    GenEvent.notify(event, {:tick})
  end

  def start_link(ms \\ 1000) do
    {:ok, event} = GenEvent.start_link
    GenServer.start_link(__MODULE__, [ms, event])
  end

  def init([ms, event]) do
    {:ok, {ms, event}}
  end

  def handle_cast({:add_tick_handler, listener}, {ms, event}) do
    GenEvent.add_handler(event, listener, [])
    {:noreply, {ms, event}}
  end

  def handle_cast({:start_timer}, {ms, event}) do
    {:ok, timer} = :timer.apply_interval(ms, __MODULE__, :_timer_interval, [event])
    {:noreply, {ms, event, timer}}
  end

  def handle_cast({:stop_timer}, {ms, event, timer}) do
    {:ok, :cancel} = :timer.cancel(timer)
    {:noreply, {ms, event}}
  end
end

