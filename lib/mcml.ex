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
    {:ok, clock} = Clock.start_link(Clock.bpm2ms(130, 4))

    {:ok, kick} = Kick.start_link
    {:ok, clap} = Clap.start_link
    {:ok, hat} = HiHat.start_link
    {:ok, piano} = Piano.start_link

    tracks = [
      { kick, [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,1,1], 1 },
      { clap, [0,0,0,0, 1,0,0,0, 0,0,0,0, 1,1,0,1], 1 },
      { hat,  [1,1,1,0, 1,1,1,1, 1,0,1,1], 1 },
      { piano,   seq1, 2 },
      { piano,   seq2, 2 }
    ]

    Enum.each(tracks, fn({i, s, d}) ->
      {:ok, seq} = StreamSequencer.start_link(Stream.cycle(s), d)
      Clock.add_tick_handler(clock, seq)
      StreamSequencer.add_step_handler(seq, i, :trigger)
    end)

    Clock.start(clock)
  end
end
