defmodule HiHat do
  def play do
    SC3.Server.send_msg("s_new", ["hat01", 1003])
  end
end
