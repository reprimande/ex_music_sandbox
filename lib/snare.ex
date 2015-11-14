defmodule Snare do
  def play do
    SC3.Server.send_msg("s_new", ["snare01", 1002])
  end
end
