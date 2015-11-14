defmodule Clap do
  def play do
    SC3.Server.send_msg("s_new", ["clap01", 1004])
  end
end
