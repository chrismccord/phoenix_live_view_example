defmodule DemoWeb.UserEditTest do
  use DemoWeb.ConnCase
  import Phoenix.LiveViewTest
  # alias Phoenix.LiveViewTest.DOM

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

  describe "user edit" do
    test "disconnected and connected mount", %{conn: conn} do
      user = user_fixture()
      conn = get(conn, "/users/#{user.id}/edit")

      assert html_response(conn, 200) =~ "Edit"

      {:ok, _view, _html} = live(conn)
    end

    test "can edit a user", %{conn: conn} do
      user = user_fixture()
      {:ok, view, html} = live(conn, "/users/#{user.id}/edit")
      assert html =~ user.email

      {:error, {:redirect, %{to: path}}} = render_submit(view, :save, %{"user" => %{"email" => "foobar@gmail.com"}})

      assert path == "/users/#{user.id}"
    end
  end
end
