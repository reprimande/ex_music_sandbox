defmodule MidiUtil do
  def note2freq(note) do 440.0 * :math.pow(2.0, (note - 69.0) / 12.0) end
end
