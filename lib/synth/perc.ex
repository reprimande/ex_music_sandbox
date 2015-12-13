defmodule Synth.Perc do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      def synth_name do
        "default"
      end

      def start_link() do
        GenServer.start_link(__MODULE__, [])
      end

      def init(_) do
        {:ok, {synth_name}}
      end

      def play(pid) do
        GenServer.cast(pid, {:play})
      end

      def handle_cast({:play}, { name }) do
        SC3.Server.send_msg("s_new", [name, SC3.Server.get_node_id, 0, 0])
        {:noreply, {name}}
      end

      def handle_cast({:trigger, 1}, { name }) do
        SC3.Server.send_msg("s_new", [name, SC3.Server.get_node_id, 0, 0])
        {:noreply, {name}}
      end

      def handle_cast({:trigger, _}, { name }) do
        {:noreply, { name }}
      end

      defoverridable [synth_name: 0]
    end
  end
end
