defmodule HiHat do
  use GenServer

  def start_link(dur \\ 0.3, opts \\ []) do
    GenServer.start_link(__MODULE__, [dur], opts)
  end

  def init([dur]) do
    {:ok, {dur}}
  end

  def play(pid) do
    GenServer.cast(pid, {:play})
  end

  def handle_cast({:play}, {dur}) do
    SC3.Server.send_msg("s_new", ["hat01", SC3.Server.get_node_id, 0, 0, "dur", dur])
    {:noreply, {dur}}
  end

  def handle_cast({:trigger, 1}, {dur}) do
    SC3.Server.send_msg("s_new", ["hat01", SC3.Server.get_node_id, 0, 0, "dur", dur])
    {:noreply, {dur}}
  end

  def handle_cast({:trigger, _}, {dur}) do
    {:noreply, {dur}}
  end
end
