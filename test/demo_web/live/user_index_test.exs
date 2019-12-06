defmodule DemoWeb.UserIndexTest do
  use DemoWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Phoenix.LiveViewTest.DOM

  alias Demo.Accounts

  def user_fixture(attrs \\ %{}) do
    valid_attrs = %{
      username: "user#{:rand.uniform(1000)}",
      email: "user-#{:rand.uniform(10000)}@test.com",
      phone_number: "555-555-5555"
    }

    {:ok, user} =
      attrs
      |> Enum.into(valid_attrs)
      |> Accounts.create_user()

    user
  end

  describe "user index" do
    test "disconnected and connected mount", %{conn: conn} do
      user = user_fixture()
      conn = get(conn, "/users")
      assert html_response(conn, 200) =~ "Listing Users"
      assert html_response(conn, 200) =~ "New User"
      assert html_response(conn, 200) =~ user.username

      {:ok, _view, _html} = live(conn)
    end
  end

  describe "user actions" do
    test "can click to next page", %{conn: conn} do
      for _i <- 1..20 do
        user_fixture()
      end
      {:ok, view, _html} = live(conn, "/users")
      render_keydown(view, :keydown, %{"code" => "ArrowRight"}) =~ "page 2"
    end

    test "can delete a user", %{conn: conn} do
      user = user_fixture()
      {:ok, view, html} = live(conn, "/users")

      assert [
         {"tr", [{"id", _}],
           [
             {"td", [], [_user_id]},
             {"td", [], [_user_email]},
             {"td", [], [_ph_number]},
             {"td", [], _}
           ]
         }
       ] = DOM.all(html, "##{user.id}")

      html = render_click(view, "delete_user", %{"user-id" => user.id})

      assert [] = DOM.all(html, "##{user.id}")
    end
  end
end
