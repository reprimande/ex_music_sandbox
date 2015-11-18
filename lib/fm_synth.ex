defmodule FmSynth do
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
    SC3.Server.send_msg("s_new", ["fmchord01", SC3.Server.get_node_id, 0, 0, "freq", MidiUtil.note2freq(note)])
    {:noreply, {}}
  end

  def handle_cast({:trigger, note}, _) do
    SC3.Server.send_msg("s_new", ["fmchord01", SC3.Server.get_node_id, 0, 0, "freq", MidiUtil.note2freq(note)])
    {:noreply, {}}
  end

  def handle_cast({:trigger, _}, _) do
    {:noreply, {}}
  end
end
