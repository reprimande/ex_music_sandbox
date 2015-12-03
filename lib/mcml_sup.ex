defmodule McmlSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def stop(sup) do
    Process.exit(sup, :normal)
  end

  def init(_) do
    supervise([worker(Mcml, [])], strategy: :one_for_one)
  end
end
