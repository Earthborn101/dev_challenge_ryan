defmodule DevChallengeRyanWeb.PageController do
  use DevChallengeRyanWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
