defmodule Piano do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, {}}
  end

  def play(pid, note) do
    GenServer.cast(pid, {:play, note})
  end

  def handle_cast({:play, note}, _) do
    play(note)
    {:noreply, {}}
  end

  def handle_cast({:trigger, note}, _) when is_list(note) or (is_integer(note) and note > 0) do
    play(note)
    {:noreply, {}}
  end

  def handle_cast({:trigger, _}, _) do
    {:noreply, {}}
  end

  defp play(notes) when is_list(notes) do
    notes |> Enum.each(&(play(&1)))
  end

  defp play(note) do
    SC3.Server.send_msg("s_new", ["piano01", SC3.Server.get_node_id, 0, 0, "freq", MidiUtil.note2freq(note)])
  end
end
