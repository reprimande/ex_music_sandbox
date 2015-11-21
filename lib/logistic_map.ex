defmodule LogisticMap do
  def start_link(r, x) do
    Agent.start_link(fn -> {r, x} end)
  end

  def next_val(pid) do
    Agent.update(pid, fn {r, x} -> {r, calc(r, x)} end)
    Agent.get(pid, fn {_, x} -> x end)
  end

  def calc(r, x) do
    r * x * (1 - x)
  end
end
