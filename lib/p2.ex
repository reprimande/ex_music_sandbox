defmodule P2 do
  def run do
    SC3.Server.start_link
    {:ok, clock} = Clock.start_link(100)

    {:ok, l} = LogisticMap.start_link(3.89, 0.1)
    {:ok, s1} = StepSequencer.start_link(fn () -> Enum.at([0,2,3,5,6,8,10], trunc(LogisticMap.next_val(l) * 7)) + 60 end)

    Clock.add_tick_handler(clock, s1)

    {:ok, fm} = FmSynth.start_link

    StepSequencer.add_step_handler(s1, fm, :trigger)

    Clock.start(clock)
  end
end
