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
    Task.start_link(fn ->
      for e <- GenEvent.stream(event) do
        GenServer.cast(listener, {event_name, e})
      end
    end)
    {:noreply, {event, pattern, current}}
  end

  def handle_cast({:tick}, {event, pattern, []}) when is_list(pattern) do
    [val|rest] = pattern
    GenEvent.notify(event, val)
    {:noreply, {event, pattern, rest}}
  end

  def handle_cast({:tick}, {event, func, []}) when is_function(func) do
    GenEvent.notify(event, func.())
    {:noreply, {event, func, []}}
  end

  def handle_cast({:tick}, {event, pattern, [val|rest]}) do
    GenEvent.notify(event, val)
    {:noreply, {event, pattern, rest}}
  end
end
