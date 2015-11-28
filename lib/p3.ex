defmodule P3 do
  def run do
    SC3.Server.start_link
    {:ok, clock} = Clock.start_link(Clock.bpm2ms(130, 4))

    {:ok, kick} = Kick.start_link
    {:ok, clap} = Clap.start_link
    {:ok, hat} = HiHat.start_link
    {:ok, bass} = Bass.start_link

    tracks = [
      { kick, [1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,1,1] },
      { clap, [0,0,0,0, 0,1,0,0, 0,0,0,1, 0,0,1,0] },
      { hat,  [1,1,1,0, 1,1,1,1, 1,0,1,1] },
      { bass, [24,36,48,36, 0,24,48,60, 24,48,0,36, 60,60,0,60] }
    ]

    Enum.each(tracks, fn({i, s}) ->
      {:ok, seq} = StreamSequencer.start_link(Stream.cycle(s))
      Clock.add_tick_handler(clock, seq)
      StreamSequencer.add_step_handler(seq, i, :trigger)
    end)

    Clock.start(clock)
  end

  def stop do
    SC3.Server.stop
  end
end
