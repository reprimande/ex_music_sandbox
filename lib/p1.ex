defmodule P1 do
  def run do
    SC3.Server.start_link
    {:ok, clock} = Clock.start_link(100)
    {:ok, s1} = StepSequencer.start_link([1,0,0,1,0,0,0,1])
    {:ok, s2} = StepSequencer.start_link([0,0,0,0,0,0,1,0])
    {:ok, s3} = StepSequencer.start_link([1,1,1,1,1,1,1,1])
    {:ok, s4} = StepSequencer.start_link([60,65,67,60,65,67,65,69])
    {:ok, s5} = StepSequencer.start_link([[60,65,67], [], [], [60,65,67], [], [60,65,67], [], [60,65,67], []])
    Clock.add_tick_handler(clock, s1)
    Clock.add_tick_handler(clock, s2)
    Clock.add_tick_handler(clock, s3)
    Clock.add_tick_handler(clock, s4)
    Clock.add_tick_handler(clock, s5)

    {:ok, kick} = Kick.start_link
    {:ok, snare} = Snare.start_link
    {:ok, hat} = HiHat.start_link
    {:ok, fm} = FmSynth.start_link

    StepSequencer.add_step_handler(s1, kick, :trigger)
    StepSequencer.add_step_handler(s2, snare, :trigger)
    StepSequencer.add_step_handler(s3, hat, :trigger)
    StepSequencer.add_step_handler(s4, fm, :trigger)
    StepSequencer.add_step_handler(s5, fm, :trigger)

    Clock.start(clock)
  end
end
