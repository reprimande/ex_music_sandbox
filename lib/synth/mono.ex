defmodule Synth.Mono do
  defmacro __using__(_opt) do
    quote do
      use GenServer

      def synth_name do "default" end

      def start_link do
        GenServer.start_link(__MODULE__, [])
      end

      def init(_) do
        node_id = SC3.Server.get_node_id
        SC3.Server.send_msg("s_new", [synth_name, node_id, 0, 0, "gate", 0])
        {:ok, {node_id}}
      end

      def handle_cast({:trigger, note}, {node_id}) when note == 0 do
        noteoff(node_id)
        {:noreply, {node_id}}
      end

      def handle_cast({:trigger, note}, {node_id}) do
        noteon(node_id, note)
        {:noreply, {node_id}}
      end

      defp noteon(node_id, note) do
        SC3.Server.send_msg("n_set", [node_id, "freq", MidiUtil.note2freq(note), "gate", 1])
      end

      defp noteoff(node_id) do
        SC3.Server.send_msg("n_set", [node_id, "gate", 0])
      end

      defoverridable [synth_name: 0]
    end
  end
end
