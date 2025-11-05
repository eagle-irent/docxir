defmodule Docxir.SpanMergerTest do
  use ExUnit.Case, async: true
  alias Docxir.SpanMerger
  doctest Docxir.SpanMerger

  describe "merge/1" do
    test "returns empty string for empty list" do
      assert SpanMerger.merge([]) == ""
    end

    test "merges adjacent inline divs with same class" do
      items = [
        ~s(<div class="inline-block text-xs">Hello</div>),
        ~s(<div class="inline-block text-xs"> World</div>)
      ]

      result = SpanMerger.merge(items)
      assert result == ~s(<div class="inline-block text-xs">Hello World</div>)
    end

    test "does not merge inline divs with different classes" do
      items = [
        ~s(<div class="inline-block text-xs">Hello</div>),
        ~s(<div class="inline-block font-bold">World</div>)
      ]

      result = SpanMerger.merge(items)
      assert result == ~s(<div class="inline-block text-xs">Hello</div><div class="inline-block font-bold">World</div>)
    end

    test "merges multiple consecutive inline divs with same class" do
      items = [
        ~s(<div class="inline-block text-base">First</div>),
        ~s(<div class="inline-block text-base"> Second</div>),
        ~s(<div class="inline-block text-base"> Third</div>)
      ]

      result = SpanMerger.merge(items)
      assert result == ~s(<div class="inline-block text-base">First Second Third</div>)
    end

    test "handles mixed plain text and inline divs" do
      items = [
        "Plain text",
        ~s(<div class="inline-block font-bold">Bold</div>)
      ]

      result = SpanMerger.merge(items)
      assert result == ~s(Plain text<div class="inline-block font-bold">Bold</div>)
    end

    test "merges complex sequence of inline divs" do
      items = [
        ~s(<div class="inline-block text-xs">A</div>),
        ~s(<div class="inline-block text-xs">B</div>),
        ~s(<div class="inline-block font-bold">C</div>),
        ~s(<div class="inline-block text-xs">D</div>),
        ~s(<div class="inline-block text-xs">E</div>)
      ]

      result = SpanMerger.merge(items)

      assert result ==
               ~s(<div class="inline-block text-xs">AB</div><div class="inline-block font-bold">C</div><div class="inline-block text-xs">DE</div>)
    end

    test "preserves inline div content with special characters" do
      items = [
        ~s(<div class="inline-block text-base">Hello & goodbye</div>),
        ~s(<div class="inline-block text-base"> <world></div>)
      ]

      result = SpanMerger.merge(items)
      assert result == ~s(<div class="inline-block text-base">Hello & goodbye <world></div>)
    end

    test "handles inline divs with multiple CSS classes" do
      items = [
        ~s(<div class="inline-block font-bold text-lg">Big</div>),
        ~s(<div class="inline-block font-bold text-lg"> Bold</div>)
      ]

      result = SpanMerger.merge(items)
      assert result == ~s(<div class="inline-block font-bold text-lg">Big Bold</div>)
    end
  end
end
