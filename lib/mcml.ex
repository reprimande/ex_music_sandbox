defmodule Mcml do
  def play do

    seq1 = [[3], [6], [3],        [-2],   [3],        [],      [],     [],
            [],  [],  [-2, 3],    [0, 6], [-2, 3],    [0, 6],  [3, 8], [0, 6],
            [3], [6], [3],        [-2],   [1],        [],      [],     [],
            [],  [],  [1, 5, 12], [],     [1, 5, 12], [8],     [1, 5], []]
    |> Enum.map(fn (c) -> Enum.map(c, fn (n) -> n + 72 end) end)

    seq2 = [[6],  [],   [],   [13], [],   [],   [],   [6],
            [8],  [],   [18], [],   [],   [],   [10], [],
            [10], [],   [17], [],   [20], [],   [],   [],
            [10], [17], [],   [],   [],   [22], [20], [15]
           ]
    |> Enum.map(fn (c) -> Enum.map(c, fn (n) -> n + 48 end) end)

    SC3.Server.start_link
    {:ok, clock} = Clock.start_link(Clock.bpm2ms(130, 2))

    {:ok, kick} = Kick.start_link
    {:ok, clap} = Clap.start_link
    {:ok, hat} = HiHat.start_link
    {:ok, fm} = FmSynth.start_link

    tracks = [
      { kick, [1,0,1,0, 1,0,1,0, 1,0,1,0, 1,0,1,1] },
      { clap, [0,0,1,0, 0,0,1,0, 0,0,1,1, 0,1,1,0] },
      { hat,  [1,1,1,0, 1,1,1,1, 1,0,1,1] },
      { fm,   seq1 },
      { fm,   seq2 }
    ]

    Enum.each(tracks, fn({i, s}) ->
      {:ok, seq} = StreamSequencer.start_link(Stream.cycle(s))
      Clock.add_tick_handler(clock, seq)
      StreamSequencer.add_step_handler(seq, i, :trigger)
    end)

    Clock.start(clock)
  end
end
