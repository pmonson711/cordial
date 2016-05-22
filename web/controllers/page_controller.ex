defmodule Cordial.PageController do
  use Cordial.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
