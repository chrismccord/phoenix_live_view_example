defmodule DemoWeb.KeyboardingView do
  use Phoenix.LiveView

  def render(assigns), do: DemoWeb.PageView.render("keyboard.html", assigns)

  @chars_per_line 30

  @meta_keys ["Meta", "Shift", "Escape", "Control", "Alt", "Backspace"]

  @fingers %{
    " " => "lf5",
    "q" => "lf4",
    "w" => "lf3",
    "e" => "lf2",
    "r" => "lf1",
    "t" => "lf1",
    "y" => "rf1",
    "u" => "rf1",
    "i" => "rf2",
    "o" => "rf3",
    "p" => "rf4",
    "a" => "lf4",
    "s" => "lf3",
    "d" => "lf2",
    "f" => "lf1",
    "g" => "lf1",
    "h" => "rf1",
    "j" => "rf1",
    "k" => "rf2",
    "l" => "rf3",
    "z" => "lf4",
    "x" => "lf3",
    "c" => "lf2",
    "v" => "lf1",
    "b" => "lf1",
    "n" => "rf1",
    "m" => "rf1"
  }

  @chapters %{
    1 => [
      "the quick brown fox jumps over the lazy log. the quick brown fox jumps over the lazy log",
      "kkkk kkkk kkkk jjjj jjjj kkkk",
      "ffff ffff ffff gggg gggg gggg ffgg ffgg ggff ggff fgfg gfgf",
      "ffkk ffkk ggjj ggjj fffk kjgg kjgf kjgf gfkk jjkg ggff gkfk"
    ]
  }
  def mount(_, socket) do
    current_chapter = 1
    current_lesson = 0

    socket =
      assign(socket,
        left_digit: 1,
        right_digit: 1,
        index: 0,
        chapter: current_chapter,
        lesson: current_lesson,
        chapter_text: get_text(current_chapter, current_lesson),
        incorrect_indexes: MapSet.new(),
        elapsed_seconds: 0,
        completed_words: 0,
        wpm: 0,
        accuracy: 100,
        correct_count: 0,
        incorrect_count: 0
      )
      |> assign_active_digit()
      |> populate_chars()
      |> tick()

    {:ok, socket}
  end

  def handle_event("keyup", _, key, socket) when key in @meta_keys do
    {:noreply, socket}
  end

  def handle_event("keyup", _, key, socket) do
    {:noreply, next_char(socket, key)}
  end

  def handle_info(:tick, socket) do
    {:noreply, tick(socket)}
  end

  defp current_char(socket) do
    %{chapter_text: text, index: index} = socket.assigns
    String.at(text, index)
  end

  defp get_text(chapter, lesson) do
    Enum.at(@chapters[chapter], lesson)
  end

  defp assign_active_digit(socket) do
    char = current_char(socket)

    case Map.fetch(@fingers, String.downcase(char)) do
      {:ok, "lf" <> digit} ->
        assign(socket, left_digit: digit, right_digit: 1)

      {:ok, "rf" <> digit} ->
        assign(socket, left_digit: 1, right_digit: digit)

      :error ->
        assign(socket, left_digit: 1, right_digit: 1)
    end
  end

  defp next_char(socket, typed_char) do
    current_char = current_char(socket)

    socket
    |> mark_correct(current_char, typed_char)
    |> update_completed_words(current_char)
    |> update(:index, &(&1 + 1))
    |> maybe_proceed_to_next_lesson()
    |> assign_active_digit()
    |> populate_chars()
  end

  defp mark_correct(socket, current_char, typed_char) do
    if current_char == typed_char do
      update(socket, :correct_count, &(&1 + 1))
    else
      socket
      |> update(:incorrect_count, &(&1 + 1))
      |> update(:incorrect_indexes, fn indexes ->
        MapSet.put(indexes, socket.assigns.index)
      end)
    end
  end

  defp maybe_proceed_to_next_lesson(socket) do
    %{index: index, chapter_text: text, lesson: lesson, chapter: chapter} = socket.assigns

    if index == String.length(text) do
      socket
      |> update(:lesson, fn _ -> lesson + 1 end)
      |> update(:index, fn _ -> 0 end)
      |> update(:chapter_text, fn _ -> get_text(chapter, lesson + 1) end)
      |> update(:incorrect_indexes, fn _ -> MapSet.new() end)
    else
      socket
    end
  end

  defp update_completed_words(socket, current_char) when current_char in [" ", "."] do
    update(socket, :completed_words, &(&1 + 1))
  end

  defp update_completed_words(socket, _current_char) do
    socket
  end

  defp tick(socket) do
    Process.send_after(self(), :tick, 1000)

    socket
    |> update(:elapsed_seconds, &(&1 + 1))
    |> calculate_wpm()
    |> calculate_accuracy()
  end

  defp calculate_wpm(socket) do
    %{elapsed_seconds: seconds, completed_words: word_count} = socket.assigns
    update(socket, :wpm, fn _ -> trunc(word_count / seconds * 60) end)
  end

  defp calculate_accuracy(socket) do
    %{incorrect_count: incorrect, correct_count: correct} = socket.assigns

    update(socket, :accuracy, fn _ ->
      trunc(max(correct, 1) / max(correct + incorrect, 1) * 100)
    end)
  end

  defp populate_chars(socket) do
    user_index = socket.assigns.index
    incorrect = socket.assigns.incorrect_indexes

    {_idx, _len, chars} =
      socket.assigns.chapter_text
      |> String.split(" ")
      |> Enum.reduce({0, 0, []}, fn word, {idx, len, acc} ->
        word_len = String.length(word)

        word
        |> String.codepoints()
        |> Enum.reduce({idx, len, acc}, fn
          char, {idx, :break, acc} ->
            {idx + 1, :break, [build_char(char, idx, user_index, incorrect) | acc]}

          char, {idx, len, acc} ->
            new_acc = [build_char(char, idx, user_index, incorrect) | acc]

            if word_len + len >= @chars_per_line do
              {idx + 1, :break, new_acc}
            else
              {idx + 1, len + 1, new_acc}
            end
        end)
        |> append_space(user_index, incorrect)
      end)

    assign(socket, :chars, Enum.reverse(chars))
  end

  defp append_space({idx, :break, acc}, idx, incorrect) do
    {idx + 1, 0, [build_char(" ", idx, idx, incorrect, %{newline: true}) | acc]}
  end

  defp append_space({idx, :break, acc}, user_index, incorrect) do
    {idx + 1, 0, [build_char(nil, idx, user_index, incorrect, %{newline: true}) | acc]}
  end

  defp append_space({idx, len, acc}, idx, incorrect) do
    {idx + 1, len, [build_char(" ", idx, idx, incorrect) | acc]}
  end

  defp append_space({idx, len, acc}, user_index, incorrect) do
    {idx + 1, len, [build_char(" ", idx, user_index, incorrect) | acc]}
  end

  defp build_char(text, idx, user_index, incorrect_indexes, attrs \\ %{}) do
    Map.merge(
      %{
        text: char_text(text),
        dim: user_index > idx,
        highlight: user_index == idx,
        newline: false,
        mark: text not in [" ", nil] && MapSet.member?(incorrect_indexes, idx)
      },
      attrs
    )
  end

  defp char_text(" "), do: raw("&nbsp;")
  defp char_text(val), do: val
end
