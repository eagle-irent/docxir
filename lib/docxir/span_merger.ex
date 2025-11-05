defmodule Docxir.SpanMerger do
  @moduledoc """
  Merges adjacent HTML inline-block div elements with identical CSS classes.

  This optimization reduces the output HTML size by combining consecutive
  inline-block div elements that have the same class attribute.

  Note: Uses inline-block divs instead of spans to allow nesting of block elements
  and provide better control over dimensions and spacing.
  """

  @doc """
  Merges adjacent inline-block divs with the same CSS class in a list of HTML fragments.

  ## Parameters

    * `items` - List of HTML fragments as strings

  ## Returns

    * String with merged adjacent inline-block divs

  ## Examples

      iex> items = [
      ...>   ~s(<div class="inline-block text-xs">Hello</div>),
      ...>   ~s(<div class="inline-block text-xs"> World</div>),
      ...>   ~s(<div class="inline-block font-bold">!</div>)
      ...> ]
      iex> Docxir.SpanMerger.merge(items)
      ~s(<div class="inline-block text-xs">Hello World</div><div class="inline-block font-bold">!</div>)

  """
  @spec merge([binary()]) :: binary()
  def merge([]), do: ""
  def merge(items) when is_list(items), do: do_merge(items, [])

  # Main merging logic using recursion
  defp do_merge([], acc), do: acc |> Enum.reverse() |> Enum.join()

  defp do_merge([current | rest], acc) do
    case parse_inline_div(current) do
      {:inline_div, class_attr, text_content} ->
        # Try to merge with subsequent inline divs of the same class
        {merged_text, remaining} = merge_same_class(rest, class_attr, text_content)
        merged_div = ~s(<div class="#{class_attr}">#{merged_text}</div>)
        do_merge(remaining, [merged_div | acc])

      :plain_text ->
        # Not an inline div, keep as is
        do_merge(rest, [current | acc])
    end
  end

  # Parse a string to check if it's an inline div element
  defp parse_inline_div(str) do
    case Regex.run(~r/^<div class="([^"]+)">(.+?)<\/div>$/s, str) do
      [_, class_attr, text_content] -> {:inline_div, class_attr, text_content}
      nil -> :plain_text
    end
  end

  # Recursively merge inline divs with the same class
  defp merge_same_class([], _class, accumulated_text), do: {accumulated_text, []}

  defp merge_same_class([next | rest] = items, target_class, accumulated_text) do
    case parse_inline_div(next) do
      {:inline_div, ^target_class, text} ->
        # Same class, continue merging
        merge_same_class(rest, target_class, accumulated_text <> text)

      _ ->
        # Different class or not an inline div, stop merging
        {accumulated_text, items}
    end
  end
end
