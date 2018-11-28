defmodule DemoWeb.PageView do
  use DemoWeb, :view

  # @chars_per_line 30

  # defp char_class(assigns, index) do
  #   cond do
  #     MapSet.member?(assigns.incorrect_indexes, index) -> "mark-char"
  #     assigns.index > index -> "dim-char"
  #     true -> ""
  #   end
  # end

  # def each_char(assigns, func) do
  #   {_idx, _len, content} =
  #     assigns.chapter_text
  #     |> String.split(" ")
  #     |> Enum.reduce({0, 0, []}, fn word, {idx, len, acc} ->
  #       word_len = String.length(word)

  #       word
  #       |> String.codepoints()
  #       |> Enum.reduce({idx, len, acc}, fn
  #         char, {idx, :break, acc} ->
  #           markup = ~E"<%= acc %><%= func.(char_text(char), idx) %>"
  #           {idx + 1, :break, markup}

  #         char, {idx, len, acc} ->
  #           markup = ~E"<%= acc %><%= func.(char_text(char), idx) %>"
  #           if word_len + len >= @chars_per_line do
  #             {idx + 1, :break, markup}
  #           else
  #             {idx + 1, len + 1, markup}
  #           end
  #       end)
  #       |> append_space(assigns.index)
  #     end)

  #   content
  # end

  # defp append_space({idx, :break, acc}, idx) do
  #   markup = ~E"""
  #   <%= acc %>
  #   <span data-char class="highlight-char underline-char">&nbsp;</span>
  #   <div class="new-line"></div>
  #   """
  #   {idx + 1, 0, markup}
  # end
  # defp append_space({idx, :break, acc}, _user_index) do
  #   markup = ~E"""
  #   <%= acc %>
  #   <div class="new-line"></div>
  #   """
  #   {idx + 1, 0, markup}
  # end
  # defp append_space({idx, len, acc}, idx) do
  #   markup = ~E"""
  #   <%= acc %>
  #   <span data-char class="highlight-char underline-char">&nbsp;</span>
  #   """
  #   {idx + 1, len, markup}
  # end
  # defp append_space({idx, len, acc}, _user_index) do
  #   markup = ~E"""
  #   <%= acc %>
  #   <span data-char>&nbsp;</span>
  #   """
  #   {idx + 1, len, markup}
  # end

  # defp char_text(" "), do: raw("&nbsp;")
  # defp char_text(char), do: char
end
