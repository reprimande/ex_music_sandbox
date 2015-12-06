defmodule LogisticMapTestSup do
  use Supervisor

  def play do
    start_link
  end

  def start_link do
    {:ok, sup} = Supervisor.start_link(__MODULE__, [])

    {:ok, c} = Supervisor.start_child(sup, worker(Clock, [100]))
    {:ok, l} = Supervisor.start_child(sup, worker(LogisticMap, [3.89, 0.1]))
    {:ok, s} = Supervisor.start_child(sup, worker(StepSequencer, [fn () -> Enum.at([0,2,3,5,6,8,10,13], trunc(LogisticMap.next_val(l) * 8)) + 72 end]))
    {:ok, fm} = Supervisor.start_child(sup, worker(FmSynth, []))

    Clock.add_tick_handler(c, s)
    StepSequencer.add_step_handler(s, fm, :trigger)
    Clock.start(c)

    {:ok, sup}
  end

  def init(_) do
    supervise([worker(SC3.Server, [])], strategy: :one_for_one)
  end

  def stop(sup) do
    SC3.Server.stop
    Process.exit(sup, :normal)
  end
end
