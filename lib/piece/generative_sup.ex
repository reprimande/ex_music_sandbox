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

    {:ok, sup} = Supervisor.start_link(__MODULE__, [])

    {:ok, fm} = Supervisor.start_child(sup, worker(FmSynth, []))
    {:ok, kick} = Supervisor.start_child(sup, worker(Kick, []))
    {:ok, snare} = Supervisor.start_child(sup, worker(Snare, []))
    {:ok, ch} = Supervisor.start_child(sup, worker(HiHat, [0.2], id: :ch1))
    {:ok, oh} = Supervisor.start_child(sup, worker(HiHat, [0.8], id: :oh1))


    perc_probs = [
      { "k", kick,  [10, 0, 2, 0, 6, 0, 2, 0, 3, 0, 6, 0, 1, 0, 2, 4] },
      { "s", snare, [0,  0, 1, 0, 1, 0, 6, 0, 6, 0, 1, 0, 1, 0, 6, 0] },
      { "ch", ch,   [10, 2, 8, 2, 1, 2] },
      { "oh", oh,   [0,  0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0] }
    ]

    {:ok, c} = Supervisor.start_child(sup, worker(Clock, [Clock.bpm2ms(80, 12)]))
    {:ok, m} = Supervisor.start_child(sup, worker(Markov, [chord_chain, :I]))
    {:ok, l} = Supervisor.start_child(sup, worker(LogisticMap, [3.89, 0.1]))

    {:ok, s1} = Supervisor.start_child(sup, worker(
          StepSequencer, [
            fn (n) ->
              Markov.next_val(m)
              |> MidiUtil.atom2chord
              |> MidiUtil.add_7th
              |> Enum.map(fn n ->
                case n do
                  n when n > 7 -> n - 12
                  _ -> n
                end
              end)
              |> Enum.map(&(&1 + 60))
          end, 12],
          id: :markov_seq))

    {:ok, s2} = Supervisor.start_child(sup, worker(
          StepSequencer, [
            fn (n) ->
              case :rand.uniform(3) do
                1 -> 0
                _ -> Enum.at(scale, trunc(LogisticMap.next_val(l) * length(scale))) + 60
              end
            end, 2],
          id: :logistic_seq))

    perc_probs |> Enum.each(fn {n, i, p} ->
      {:ok, s} = Supervisor.start_child(sup, worker(
            StepSequencer, [
            fn (n) ->
              len = length(p)
              index = rem(n, len)
              val = p |> Enum.at(index)
              case :rand.uniform(9) do
                n when n < val -> 1
                _ -> 0
              end
            end, 1],
      id: n <> "_seq"))
      Clock.add_tick_handler(c, s)
      StepSequencer.add_step_handler(s, i, :trigger)
    end)

    Clock.add_tick_handler(c, s1)
    Clock.add_tick_handler(c, s2)

    StepSequencer.add_step_handler(s1, fm, :trigger)
    StepSequencer.add_step_handler(s2, fm, :trigger)
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
