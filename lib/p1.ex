defmodule P1 do
  def run do
    SC3.Server.start_link
    {:ok, clock} = Clock.start_link(100)
    {:ok, s1} = StepSequencer.start_link([1,0,0,1,0,0,0,1])
    {:ok, s2} = StepSequencer.start_link([0,0,0,0,0,0,1,0])
    {:ok, s3} = StepSequencer.start_link([1,1,1,1,1,1,1,1])
    Clock.add_tick_handler(clock, s1)
    Clock.add_tick_handler(clock, s2)
    Clock.add_tick_handler(clock, s3)

    {:ok, kick} = Kick.start_link
    {:ok, snare} = Snare.start_link
    {:ok, hat} = HiHat.start_link

    StepSequencer.add_step_handler(s1, kick, :trigger)
    StepSequencer.add_step_handler(s2, snare, :trigger)
    StepSequencer.add_step_handler(s3, hat, :trigger)

    Clock.start(clock)
  end
end
