defmodule Docxir.HtmlBuilder do
  @moduledoc """
  Builds complete HTML documents with Tailwind CSS.

  This module generates the HTML structure including the document head,
  Tailwind CSS CDN link, and styling for optimal display.
  """

  @doc """
  Creates a complete HTML document from body content.

  ## Parameters

    * `body_html` - The HTML content for the body
    * `opts` - Keyword list of options
      * `:title` - Document title (default: "Document")
      * `:lang` - Language code (default: "zh-TW")

  ## Returns

    * Complete HTML document as a string

  ## Examples

      iex> body = "<p>Hello World</p>"
      iex> html = Docxir.HtmlBuilder.build(body, title: "Test Doc")
      iex> html =~ "<title>Test Doc</title>"
      true

  """
  @spec build(binary(), keyword()) :: binary()
  def build(body_html, opts \\ []) do
    title = Keyword.get(opts, :title, "Document")
    lang = Keyword.get(opts, :lang, "zh-TW")

    """
    <!DOCTYPE html>
    <html lang="#{lang}">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>#{escape_html(title)}</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI",
                             "PingFang TC", "Microsoft JhengHei", "Noto Sans TC",
                             sans-serif;
            }
        </style>
    </head>
    <body class="max-w-4xl mx-auto p-8 bg-gray-50">
        <div class="bg-white shadow-lg rounded-lg p-8">
            #{body_html}
        </div>
    </body>
    </html>
    """
  end

  # Escape HTML special characters in title
  defp escape_html(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end
end
