defmodule LogisticMap do
  def start_link(r, x) do
    Agent.start_link(fn -> {r, x} end)
  end

  def calc(r, x) do
    r * x * (1 - x)
  end

  def next_val(pid) do
    Agent.get_and_update(pid, fn {r, x} ->
      z = calc(r, x)
      {z, {r, z}}
    end)
  end

  def next_val(pid, list) when is_list(list) do
    list |> Enum.at(trunc(next_val(pid) * length(list)))
  end
end
