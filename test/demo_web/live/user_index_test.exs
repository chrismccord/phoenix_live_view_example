defmodule DemoWeb.UserIndexTest do
  use DemoWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "user index" do
    test "disconnected and connected mount", %{conn: conn} do
      conn = get(conn, "/users")
      assert html_response(conn, 200) =~ "Listing Users"

      {:ok, view, html} = live(conn)
    end
  end
end
