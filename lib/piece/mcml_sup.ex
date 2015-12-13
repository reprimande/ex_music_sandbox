defmodule McmlSup do
  use Supervisor

  def play do
    start_link
  end

  def start_link do
    {:ok, sup} = Supervisor.start_link(__MODULE__, [])

    seq1 = [[3], [6], [3],        [-2],   [3],        [],      [],     [],
            [],  [],  [-2, 3],    [0, 6], [-2, 3],    [0, 6],  [3, 8], [0, 6],
            [3], [6], [3],        [-2],   [1],        [],      [],     [],
            [],  [],  [1, 5, 12], [],     [1, 5, 12], [8],     [1, 5], []
           ] |> Enum.map(fn (c) -> Enum.map(c, fn (n) -> n + 72 end) end)

    seq2 = [[-6], [],  [],  [1], [],  [],   [],   [-6],
            [-4], [],  [6], [],  [],  [],   [10], [],
            [-2], [],  [5], [],  [8], [],   [],   [],
            [-2], [5], [],  [],  [],  [10], [8],  [3]
           ] |> Enum.map(fn (c) -> Enum.map(c, fn (n) -> n + 60 end) end)

    {:ok, clock} = Supervisor.start_child(sup, worker(Clock, [Clock.bpm2ms(125, 4)]))

    [
      { "kick",    Kick,  [],    [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,1,1, 1,0,0,0, 1,0,0,0, 1,0,0,1, 1,0,0,1], 1 },
      { "clap",    Clap,  [],    [0,0,0,0, 1,0,0,0, 0,0,0,0, 1,1,0,1, 0,0,0,0, 1,0,0,0, 0,0,1,0, 0,1,1,0], 1 },
      { "snare",   Snare, [],    [0,0,0,0, 0,0,1,0, 0,0,1,1, 0,1,0,1, 0,0,0,1, 0,0,1,0, 0,0,0,1, 0,0,1,1], 1 },
      { "ch",      HiHat, [0.3], [1,1,0,0, 1,1,0,0, 1,1,0,0, 1,0,0,1], 1 },
      { "oh",      HiHat, [0.8], [0,0,1,0, 0,0,1,0, 0,0,1,0, 0,1,1,0], 1 },
      { "piano_r", Piano, [],    seq1, 2 },
      { "piano_l", Piano, [],    seq2, 2 }
    ] |>  Enum.each(fn({n, m, o, p, d}) ->
      {:ok, inst} = Supervisor.start_child(sup, worker(m, o, id: n <> "_inst"))
      {:ok, seq} = Supervisor.start_child(sup, worker(StepSequencer, [p, d], id: n <> "_seq"))
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
