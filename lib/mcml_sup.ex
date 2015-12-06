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

    Supervisor.start_child(sup, worker(SC3.Server.start_link, []))

    {:ok, clock} = Supervisor.start_child(sup, worker(Clock, [Clock.bpm2ms(130, 4)]))

    {:ok, kick} = Supervisor.start_child(sup, worker(Kick, []))
    {:ok, clap} = Supervisor.start_child(sup, worker(Clap, []))
    {:ok, snare} = Supervisor.start_child(sup, worker(Snare, []))
    {:ok, ch} = Supervisor.start_child(sup, worker(HiHat, [0.3], id: :ch1))
    {:ok, oh} = Supervisor.start_child(sup, worker(HiHat, [0.8], id: :oh1))
    {:ok, piano} = Supervisor.start_child(sup, worker(Piano, []))

    [
      { :kick, kick,  [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,1,1, 1,0,0,0, 1,0,0,0, 1,0,0,1, 1,0,0,1], 1 },
      { :clap, clap,  [0,0,0,0, 1,0,0,0, 0,0,0,0, 1,1,0,1, 0,0,0,0, 1,0,0,0, 0,0,1,0, 0,1,1,0], 1 },
      { :snare, snare, [0,0,0,0, 0,0,1,0, 0,0,1,1, 0,1,0,1, 0,0,0,1, 0,0,1,0, 0,0,0,1, 0,0,1,1], 1 },
      { :ch, ch,    [1,1,0,0, 1,1,0,0, 1,1,0,0, 1,0,0,1], 1 },
      { :oh, oh,    [0,0,1,0, 0,0,1,0, 0,0,1,0, 0,1,1,0], 1 },
      { :piano_r, piano, seq1, 2 },
      { :piano_l, piano, seq2, 2 }
    ] |>  Enum.each(fn({n, i, s, d}) ->
      {:ok, seq} = Supervisor.start_child(sup, worker(StreamSequencer, [Stream.cycle(s), d], id: n))

      Clock.add_tick_handler(clock, seq)
      StreamSequencer.add_step_handler(seq, i, :trigger)
    end)

    Clock.start(clock)

    {:ok, sup}
  end

  def init(_) do
    supervise([], strategy: :one_for_one)
  end

  def stop(sup) do
    SC3.Server.stop
    Process.exit(sup, :normal)
  end
end
