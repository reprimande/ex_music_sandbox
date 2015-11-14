defmodule Kick do
  def play do
    SC3.Server.send_msg("s_new", ["kick01", 1001])
  end
end
