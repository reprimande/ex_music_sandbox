defmodule GenerativeTestSup do
  use Supervisor

  def play do
    start_link
  end

  def start_link do
    chord_chain = %{
      I:   [:ii, :iii, :IV, :V, :vi, :vii],
      ii:  [:V, :vii],
      iii: [:IV, :vi],
      IV:  [:ii, :V, :vii],
      V:   [:vi, :I],
      vi:  [:ii, :IV, :V],
      vii: [:I]
    }
    scale = [0,2,4,5,7,9,11,12,14,16,17,19,21,23,24]
    perc_probs = [
      { "kick",  Kick,  [],    [10, 0, 2, 0, 6, 0, 2, 0, 3, 0, 6, 0, 1, 0, 2, 4] },
      { "snare", Snare, [],    [0,  0, 1, 0, 1, 0, 6, 0, 6, 0, 1, 0, 1, 0, 6, 0] },
      { "ch",    HiHat, [0.3], [10, 2, 8, 2, 1, 2] },
      { "oh",    HiHat, [0.8], [0,  0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0] }
    ]

    {:ok, sup} = Supervisor.start_link(__MODULE__, [])

    {:ok, c} = Supervisor.start_child(sup, worker(Clock, [Clock.bpm2ms(80, 12)]))

    {:ok, fm} = Supervisor.start_child(sup, worker(FmSynth, []))
    {:ok, m} = Supervisor.start_child(sup, worker(Markov, [chord_chain, :I]))
    {:ok, s1} = Supervisor.start_child(
      sup, worker(
        StepSequencer,
        [fn (_) ->
          Markov.next_val(m)
          |> MidiUtil.atom2chord
          |> MidiUtil.add_7th
          |> MidiUtil.simple_invert(7)
          |> Enum.map(&(&1 + 60))
        end, 12],
        id: :markov_seq))
    Clock.add_tick_handler(c, s1)
    StepSequencer.add_step_handler(s1, fm, :trigger)

    {:ok, l} = Supervisor.start_child(sup, worker(LogisticMap, [3.8, 0.1]))
    {:ok, s2} = Supervisor.start_child(
      sup, worker(
        StepSequencer,
        [fn (_) ->
          case :rand.uniform(3) do
            1 -> 0
            _ -> LogisticMap.next_val(l, scale) + 60
          end
        end, 2],
        id: :logistic_seq))
    Clock.add_tick_handler(c, s2)
    StepSequencer.add_step_handler(s2, fm, :trigger)

    perc_probs |> Enum.each(fn {name, module, params, prob} ->
      {:ok, i} = Supervisor.start_child(
        sup, worker(module, params, id: name <> "_inst"))
      {:ok, p} = Supervisor.start_child(
        sup, worker(Prob, [prob], id: name <> "_prob"))
      {:ok, s} = Supervisor.start_child(
        sup, worker(
          StepSequencer,
          [fn (step) -> Prob.val(p, step) end, 1],
          id: name <> "_seq"))
      Clock.add_tick_handler(c, s)
      StepSequencer.add_step_handler(s, i, :trigger)
    end)

    Clock.start(c)
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
