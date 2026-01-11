defmodule PubliiExWeb.PageController do
  use PubliiExWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
