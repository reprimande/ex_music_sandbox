defmodule StreamSequencer do
  def start_link(stream) do
    GenServer.start_link(__MODULE__, [stream])
  end

  def init([stream]) do
    {:ok, event} = GenEvent.start_link
    {:ok, %{ step: 0, stream: stream, event: event }}
  end

  def add_step_handler(pid, listener, event_name) do
    GenServer.cast(pid, {:add_step_handler, listener, event_name})
  end

  def handle_cast({:add_step_handler, listener, event_name}, state) do
    Task.start(fn ->
      for x <- GenEvent.stream(state.event) do
        GenServer.cast(listener, {event_name, x})
      end
    end)
    {:noreply, {state}}
  end

  def handle_cast({:tick}, state) do
    GenEvent.notify(state.event, state.stream |> Enum.at(state.step))
    {:noreply, %{ step: state.step + 1, stream: state.stream, event: state.event }}
  end
end
