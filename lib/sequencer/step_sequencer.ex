defmodule StepSequencer do
  def start_link(pattern, div \\ 1) do
    GenServer.start_link(__MODULE__, [pattern, div])
  end

  def init([pattern, div]) do
    {:ok, event} = GenEvent.start_link
    {:ok, {event, pattern, [], 0, div}}
  end

  def add_step_handler(pid, listener, event_name) do
    GenServer.cast(pid, {:add_step_handler, listener, event_name})
  end

  def handle_cast({:add_step_handler, listener, event_name}, {event, pattern, current, step, div}) do
    Task.start(fn ->
      for e <- GenEvent.stream(event) do
        GenServer.cast(listener, {event_name, e})
      end
    end)
    {:noreply, {event, pattern, current, step, div}}
  end

  def handle_cast({:tick}, {event, pattern, [], step, div}) when is_list(pattern) and rem(step, div) == 0 do
    GenEvent.notify(event, hd(pattern))
    {:noreply, {event, pattern, tl(pattern), step + 1, div}}
  end

  def handle_cast({:tick}, {event, pattern, [val|rest], step, div}) when is_list(pattern) and rem(step, div) == 0  do
    GenEvent.notify(event, val)
    {:noreply, {event, pattern, rest, step + 1, div}}
  end

  def handle_cast({:tick}, {event, func, [], step, div}) when is_function(func) and rem(step, div) == 0  do
    GenEvent.notify(event, func.(step))
    {:noreply, {event, func, [], step + 1, div}}
  end

  def handle_cast({:tick}, { event, pattern, current, step, div }) do
    {:noreply, {event, pattern, current, step + 1, div}}
  end
end
