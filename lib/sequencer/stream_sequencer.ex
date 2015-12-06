defmodule StreamSequencer do
  use GenServer

  def start_link(stream, div \\ 1) do
    GenServer.start_link(__MODULE__, [stream, div])
  end

  def init([stream, div]) do
    {:ok, event} = GenEvent.start_link
    {:ok, %{ step: 0, stream: stream, event: event, div: div }}
  end

  def add_step_handler(pid, listener, event_name) do
    GenServer.cast(pid, {:add_step_handler, listener, event_name})
  end

  def handle_cast({:add_step_handler, listener, event_name}, state) do
    Task.start_link(fn ->
      for e <- GenEvent.stream(state.event) do
        GenServer.cast(listener, {event_name, e})
      end
    end)
    {:noreply, state}
  end

  def handle_cast({:tick}, state) do
    if state.step == 0 || rem(state.step, state.div) == 0 do
      GenEvent.notify(state.event, state.stream |> Enum.at(trunc(state.step / state.div)))
    end
    {:noreply, %{ step: state.step + 1, stream: state.stream, event: state.event, div: state.div }}
  end

  def handle_cast({:tick}, state) do
    {:noreply, %{ step: state.step + 1, stream: state.stream, event: state.event }}
  end
end
