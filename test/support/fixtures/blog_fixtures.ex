defmodule Demo.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Demo.Blog` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        age: 42,
        title: "some title"
      })
      |> Demo.Blog.create_post()

    post
  end
end
