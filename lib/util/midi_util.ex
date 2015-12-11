defmodule MidiUtil do
  def note2freq(note) do 440.0 * :math.pow(2.0, (note - 69.0) / 12.0) end

  def major do [0, 4, 7] end

  def minor do [0, 3, 7] end

  def add_7th([root|rest]) do
    [root, rest, root + 10] |> List.flatten
  end

  def atom2chord(atom) do
    case atom do
      :I   -> major
      :II  -> major |> Enum.map(&(&1 + 2))
      :III -> major |> Enum.map(&(&1 + 4))
      :IV  -> major |> Enum.map(&(&1 + 6))
      :V   -> major |> Enum.map(&(&1 + 7))
      :VI  -> major |> Enum.map(&(&1 + 9))
      :VII -> [11, 14, 17]
      :i   -> minor
      :ii  -> minor |> Enum.map(&(&1 + 2))
      :iii -> minor |> Enum.map(&(&1 + 4))
      :iv  -> minor |> Enum.map(&(&1 + 6))
      :v   -> minor |> Enum.map(&(&1 + 7))
      :vi  -> minor |> Enum.map(&(&1 + 9))
      :vii -> [11, 13, 17]
      _ -> []
    end
  end

  def simple_invert(chord, thresh) do
    chord |> Enum.map(fn n ->
      case n do
        n when n > thresh -> n - 12
        _ -> n
      end
    end)
  end
end
