# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Demo.Repo.insert!(%Demo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


for i <- 1..1000 do
  artworks = [
    "https://s3.amazonaws.com/uifaces/faces/twitter/jarjan/128.jpg",
    "https://s3.amazonaws.com/uifaces/faces/twitter/aio___/128.jpg",
    "https://s3.amazonaws.com/uifaces/faces/twitter/kolage/128.jpg",
    "https://s3.amazonaws.com/uifaces/faces/twitter/sauro/128.jpg",
    "https://s3.amazonaws.com/uifaces/faces/twitter/jina/128.jpg"
  ]

  {:ok, _} =
    Demo.Accounts.create_user(%{
      username: "user#{i}",
      name: "User #{i}",
      artwork: %{
        url: Enum.take_random(artworks, 1) |> Enum.at(0),
        height: 65,
        width: 65
      },
      email: "user#{i}@test",
      phone_number: "555-555-5555"
    })
end
