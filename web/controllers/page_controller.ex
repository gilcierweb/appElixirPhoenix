defmodule AppElixirPhoenix.PageController do
  use AppElixirPhoenix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
