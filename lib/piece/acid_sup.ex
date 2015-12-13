defmodule AcidSup do
  use Supervisor

  def play do
    start_link
  end

  def start_link do
    {:ok, sup} = Supervisor.start_link(__MODULE__, [])

    {:ok, clock} = Supervisor.start_child(sup, worker(Clock, [Clock.bpm2ms(135, 4)]))

    [
      { "s1", Kick,  [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,1,1] },
      { "s2", Clap,  [0,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,1,0] },
      { "s3", HiHat, [1,1,1,0, 1,1,1,1, 1,0,1,1] },
      { "s4", Bass,  [24,36,48,36, 0,24,48,60, 24,48,0,36, 60,60,0,60] }
    ] |>  Enum.each(fn({n, m, p}) ->
      {:ok, inst} = Supervisor.start_child(sup, worker(m, [], id: n <> "_inst"))
      {:ok, seq} = Supervisor.start_child(sup, worker(StepSequencer, [p], id: n <> "_seq"))
      Clock.add_tick_handler(clock, seq)
      StepSequencer.add_step_handler(seq, inst, :trigger)
    end)

    Clock.start(clock)

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
