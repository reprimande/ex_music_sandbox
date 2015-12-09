defmodule Markov do
  def start_link(dict, start_val) do
    Agent.start_link(fn -> {dict, start_val} end)
  end

  def next_val(pid) do
    Agent.get_and_update(pid, fn {dict, val} ->
      {val, {dict, dict[val] |> Enum.random}}
    end)
  end
end
