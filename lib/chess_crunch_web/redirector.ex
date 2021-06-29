defmodule ChessCrunchWeb.Redirector do
  def init([to: _] = opts), do: opts
  def init(_opts), do: raise("Missing required `to:` option")

  def call(conn, opts), do: Phoenix.Controller.redirect(conn, opts)
end
