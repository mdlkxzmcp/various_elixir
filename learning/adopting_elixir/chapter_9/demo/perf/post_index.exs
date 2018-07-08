defmodule PostIndex do
  @moduledoc """
  Module used for profiling of the `POST` action for the index page. Refer to the README.md for more on the subject.
  """
  use Phoenix.ConnTest
  @endpoint DemoWeb.Endpoint

  import DemoWeb.Router.Helpers
  import ExUnit.Assertions

  def run do
    conn = build_conn()
    conn = get(conn, post_path(conn, :index))
    assert html_response(conn, 200)
  end
end
