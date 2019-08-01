defmodule DemoWeb.ThermostatLiveTest do
  use DemoWeb.ConnCase
  import Phoenix.LiveViewTest

  test "clicking + makes the number go up", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/thermostat")
    assert render_click(view, "inc", "+") =~ "73"
  end
end
