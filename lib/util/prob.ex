defmodule Prob do
  def start_link(prob) do
    Agent.start_link(fn -> prob end)
  end

  def val(pid, step) do
    val = Agent.get(pid, fn prob ->
      prob |> Enum.at(rem(step, length(prob)))
    end)
    case :rand.uniform(9) do
      n when n < val -> 1
      _ -> 0
    end
  end
end
