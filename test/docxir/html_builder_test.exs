defmodule Docxir.HtmlBuilderTest do
  use ExUnit.Case, async: true
  alias Docxir.HtmlBuilder
  doctest Docxir.HtmlBuilder

  describe "build/2" do
    test "generates complete HTML document" do
      body = "<div>Test content</div>"
      html = HtmlBuilder.build(body)

      assert html =~ "<!DOCTYPE html>"
      assert html =~ ~r/<html lang="zh-TW">/
      assert html =~ "<div>Test content</div>"
    end

    test "includes Tailwind CSS CDN" do
      html = HtmlBuilder.build("")
      assert html =~ "https://cdn.tailwindcss.com"
    end

    test "uses default title when not provided" do
      html = HtmlBuilder.build("")
      assert html =~ "<title>Document</title>"
    end

    test "uses custom title from options" do
      html = HtmlBuilder.build("", title: "My Custom Title")
      assert html =~ "<title>My Custom Title</title>"
    end

    test "uses custom language from options" do
      html = HtmlBuilder.build("", lang: "en")
      assert html =~ ~r/<html lang="en">/
    end

    test "escapes HTML in title" do
      html = HtmlBuilder.build("", title: "Title with <script>")
      assert html =~ "&lt;script&gt;"
      refute html =~ "<script>"
    end

    test "includes required meta tags" do
      html = HtmlBuilder.build("")
      assert html =~ ~s(<meta charset="UTF-8">)
      assert html =~ ~s(<meta name="viewport")
    end

    test "includes Tailwind container styling" do
      html = HtmlBuilder.build("")
      assert html =~ "max-w-4xl"
      assert html =~ "bg-white"
      assert html =~ "shadow-lg"
    end

    test "includes Chinese font family" do
      html = HtmlBuilder.build("")
      assert html =~ "PingFang TC"
      assert html =~ "Microsoft JhengHei"
    end
  end
end
