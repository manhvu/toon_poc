defmodule ToonAppWeb.PageController do
  use ToonAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
