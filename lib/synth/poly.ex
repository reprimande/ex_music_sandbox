defmodule Synth.Poly do
  defmacro __using__(_opt) do
    quote do
      use GenServer

      def synth_name do
        "default"
      end

      def start_link do
        GenServer.start_link(__MODULE__, [])
      end

      def init(_) do
        {:ok, {synth_name}}
      end

      def play(pid, note) do
        GenServer.cast(pid, {:play, note})
      end

      def handle_cast({:play, note}, {name}) do
        send_msg(name, note)
        {:noreply, {name}}
      end

      def handle_cast({:trigger, note}, {name}) when is_list(note) or (is_integer(note) and note > 0) do
        send_msg(name, note)
        {:noreply, {name}}
      end

      def handle_cast({:trigger, _}, {name}) do
        {:noreply, {name}}
      end

      defp send_msg(name, notes) when is_list(notes) do
        notes |> Enum.each(&(send_msg(name, &1)))
      end

      defp send_msg(name, note) do
        SC3.Server.send_msg(
          "s_new", [name, SC3.Server.get_node_id, 0, 0, "freq", MidiUtil.note2freq(note)])
      end

      defoverridable [synth_name: 0]
    end
  end
end
