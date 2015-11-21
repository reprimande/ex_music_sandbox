defmodule P2 do
  def run do
    SC3.Server.start_link
    {:ok, clock} = Clock.start_link(100)

    {:ok, l} = LogisticMap.start_link(3.8, 0.5)
    {:ok, s1} = StepSequencer.start_link(fn () -> Enum.at([0,2,3,5,7,9,10], round(LogisticMap.next_val(l) * 6)) + 60 end)

    Clock.add_tick_handler(clock, s1)

    {:ok, fm} = FmSynth.start_link

    StepSequencer.add_step_handler(s1, fm, :trigger)

    Clock.start(clock)
  end
end
