defmodule StepSequencer do
  def start_link(pattern) do
    GenServer.start_link(__MODULE__, [pattern])
  end

  def init([pattern]) do
    {:ok, event} = GenEvent.start_link
    {:ok, {event, pattern, []}}
  end

  def add_step_handler(pid, listener, event_name) do
    GenServer.cast(pid, {:add_step_handler, listener, event_name})
  end

  def handle_cast({:add_step_handler, listener, event_name}, {event, pattern, current}) do
    Task.start(fn ->
      for x <- GenEvent.stream(event) do
        GenServer.cast(listener, {event_name, x})
      end
    end)
    {:noreply, {event, pattern, current}}
  end

  def handle_cast({:tick}, {event, pattern, []}) do
    GenEvent.notify(event, hd(pattern))
    {:noreply, {event, pattern, tl(pattern)}}
  end

  def handle_cast({:tick}, {event, pattern, current}) do
    GenEvent.notify(event, hd(current))
    {:noreply, {event, pattern, tl(current)}}
  end
end
