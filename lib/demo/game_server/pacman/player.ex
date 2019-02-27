defmodule Demo.GameServer.Pacman.Player do
  @type heading :: :left | :right | :up | :down

  @type t :: %__MODULE__{
          x: integer(),
          y: integer(),
          color: String.t(),
          pid: pid(),
          heading: heading(),
          rotation: integer(),
          score: integer(),
          name: String.t()
        }

  defstruct x: nil,
            y: nil,
            heading: nil,
            color: nil,
            pid: nil,
            rotation: nil,
            score: 0,
            name: nil

  def new(owner_pid) do
    %__MODULE__{
      x: 1,
      y: 1,
      heading: :right,
      color: random_color(),
      pid: owner_pid,
      rotation: 0,
      name: random_name()
    }
  end

  def set_color(%__MODULE__{} = player, color) when is_binary(color) do
    %__MODULE__{player | color: color}
  end

  defp random_color do
    random_color_part() <> random_color_part() <> random_color_part()
  end

  defp random_color_part, do: (:rand.uniform(205) + 50) |> Integer.to_string(16)

  defp random_name, do: "pacman#{:random.uniform(9_999)}"
end
