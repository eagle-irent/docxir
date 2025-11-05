defmodule Docxir.Parser do
  @moduledoc """
  Parses Word document XML into HTML with Tailwind CSS classes.

  This module handles the conversion of Word XML elements (paragraphs, runs,
  tables) into corresponding HTML elements styled with Tailwind CSS.

  ## HTML Structure

  - **Paragraphs**: Converted to `<div>` elements with Tailwind CSS classes
  - **Text runs**: Plain text or `<div class="inline-block">` elements with styling classes
  - **Tables**: Standard HTML `<table>` structure

  All styled text uses inline-block divs instead of spans to allow nesting of block elements
  and provide better control over padding, margin, and dimensions.

  ## Supported Features

  - **Paragraphs**: Alignment, indentation, spacing
  - **Text Styling**: Bold, italic, underline, font sizes
  - **Tables**: Basic structure with colspan support
  - **Page Breaks**: Both manual (`<w:br w:type="page"/>`) and paragraph-level (`<w:pageBreakBefore/>`)

  ## Page Break Handling

  Page breaks are converted to Tailwind CSS print utilities:

  - `<w:pageBreakBefore/>` in paragraph properties → `break-before-page` class on div
  - `<w:br w:type="page"/>` in run → `<div class="break-after-page"></div>` element

  These classes work with Tailwind's print utilities to create page breaks when printing or generating PDFs.
  """

  import SweetXml
  alias Docxir.{StyleMapper, SpanMerger}

  # Word XML namespace prefix
  @w_ns "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

  @doc """
  Parses Word document XML content into HTML.

  Processes paragraphs and tables in document order, preserving the sequence
  they appear in the original Word document.

  ## Parameters

    * `xml_content` - The document.xml content as binary

  ## Returns

    * HTML body content as a string

  ## Examples

      iex> xml = "<w:document xmlns:w=\\"#{@w_ns}\\"><w:body><w:p><w:r><w:t>Hello</w:t></w:r></w:p></w:body></w:document>"
      iex> html = Docxir.Parser.parse(xml)
      iex> html =~ "Hello"
      true

  """
  @spec parse(binary()) :: binary()
  def parse(xml_content) do
    body_elem =
      xml_content
      |> xpath(~x"//w:body"e |> add_namespace("w", @w_ns))

    # Get direct children and filter for paragraphs and tables
    # This preserves document order
    children = get_children(body_elem)

    children
    |> Enum.filter(&is_paragraph_or_table?/1)
    |> Enum.map(&parse_element/1)
    |> Enum.join("\n")
  end

  # Get child elements from an XML element
  defp get_children(elem) do
    case elem do
      {:xmlElement, _, _, _, _, _, _, _, children, _, _, _} -> children
      _ -> []
    end
  end

  # Check if element is a paragraph or table
  defp is_paragraph_or_table?(elem) do
    case elem do
      {:xmlElement, name, _, _, _, _, _, _, _, _, _, _} when name in [:"w:p", :"w:tbl"] -> true
      _ -> false
    end
  end

  # Parse a single element (paragraph or table)
  defp parse_element(element) do
    case elem(element, 0) do
      :xmlElement ->
        element_name = elem(element, 1)

        case element_name do
          :"w:p" -> parse_paragraph(element)
          :"w:tbl" -> parse_table(element)
          _ -> ""
        end

      _ ->
        ""
    end
  end

  # Parse a paragraph element
  defp parse_paragraph(para_elem) do
    # Extract paragraph properties
    classes = ["mb-2"] ++ parse_paragraph_properties(para_elem)

    # Extract and parse all runs
    runs =
      para_elem
      |> xpath(~x".//w:r"el |> add_namespace("w", @w_ns))
      |> Enum.map(&parse_run/1)
      |> Enum.reject(&(&1 == ""))

    # Merge adjacent spans with same classes
    content = SpanMerger.merge(runs)

    # Handle empty paragraphs
    if String.trim(content) == "" do
      ~s(<div class="mb-1"></div>)
    else
      class_str = Enum.join(classes, " ")
      ~s(<div class="#{class_str}">#{content}</div>)
    end
  end

  # Extract paragraph formatting properties
  defp parse_paragraph_properties(para_elem) do
    classes = []

    # Page break before paragraph
    classes =
      if xpath(para_elem, ~x".//w:pPr/w:pageBreakBefore"e |> add_namespace("w", @w_ns)) != nil do
        classes ++ ["break-before-page"]
      else
        classes
      end

    # Alignment
    classes =
      case xpath(para_elem, ~x".//w:pPr/w:jc/@w:val"s |> add_namespace("w", @w_ns)) do
        nil -> classes
        "" -> classes
        jc_val -> classes ++ [StyleMapper.alignment_class(to_string(jc_val))]
      end

    # Indentation
    classes =
      case xpath(para_elem, ~x".//w:pPr/w:ind/@w:left"s |> add_namespace("w", @w_ns)) do
        nil ->
          classes

        "" ->
          classes

        indent_val ->
          indent_class = StyleMapper.indent_class(to_string(indent_val))
          if indent_class != "", do: classes ++ [indent_class], else: classes
      end

    classes
  end

  # Parse a run (text segment with formatting)
  defp parse_run(run_elem) do
    # Check for page break in run
    has_page_break =
      case xpath(run_elem, ~x".//w:br/@w:type"s |> add_namespace("w", @w_ns)) do
        nil -> false
        "" -> false
        type_val -> to_string(type_val) == "page"
      end

    # If this run contains a page break, return a page break element
    if has_page_break do
      ~s(<div class="break-after-page"></div>)
    else
      # Extract text
      text =
        case xpath(run_elem, ~x".//w:t/text()"s |> add_namespace("w", @w_ns)) do
          nil -> ""
          t -> to_string(t)
        end

      if text == "" do
        ""
      else
        # Parse run properties for styling
        classes = parse_run_properties(run_elem)

        if classes == [] do
          text
        else
          # Add inline-block class to allow nesting block elements inside
          class_str = Enum.join(["inline-block"] ++ classes, " ")
          ~s(<div class="#{class_str}">#{text}</div>)
        end
      end
    end
  end

  # Extract run formatting properties
  defp parse_run_properties(run_elem) do
    classes = []

    # Bold
    classes =
      if xpath(run_elem, ~x".//w:rPr/w:b"e |> add_namespace("w", @w_ns)) != nil do
        classes ++ ["font-bold"]
      else
        classes
      end

    # Italic
    classes =
      if xpath(run_elem, ~x".//w:rPr/w:i"e |> add_namespace("w", @w_ns)) != nil do
        classes ++ ["italic"]
      else
        classes
      end

    # Underline
    classes =
      if xpath(run_elem, ~x".//w:rPr/w:u"e |> add_namespace("w", @w_ns)) != nil do
        classes ++ ["underline"]
      else
        classes
      end

    # Font size
    case xpath(run_elem, ~x".//w:rPr/w:sz/@w:val"s |> add_namespace("w", @w_ns)) do
      nil -> classes
      "" -> classes
      sz_val -> classes ++ [StyleMapper.font_size_class(to_string(sz_val))]
    end
  end

  # Parse a table
  defp parse_table(tbl_elem) do
    rows =
      tbl_elem
      |> xpath(~x".//w:tr"el |> add_namespace("w", @w_ns))
      |> Enum.map(&parse_table_row/1)
      |> Enum.join("\n")

    """
    <table class="w-full border-collapse border border-gray-400 my-4">
    #{rows}
    </table>
    """
  end

  # Parse a table row
  defp parse_table_row(tr_elem) do
    cells =
      tr_elem
      |> xpath(~x".//w:tc"el |> add_namespace("w", @w_ns))
      |> Enum.map(&parse_table_cell/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.join("")

    "<tr>#{cells}</tr>"
  end

  # Parse a table cell
  defp parse_table_cell(tc_elem) do
    # Check for gridSpan (colspan)
    colspan =
      case xpath(tc_elem, ~x".//w:tcPr/w:gridSpan/@w:val"s |> add_namespace("w", @w_ns)) do
        nil -> 1
        "" -> 1
        val -> String.to_integer(to_string(val))
      end

    # Check for vertical merge (skip merged cells)
    v_merge =
      case xpath(tc_elem, ~x".//w:tcPr/w:vMerge/@w:val"s |> add_namespace("w", @w_ns)) do
        nil -> ""
        val -> to_string(val)
      end

    if v_merge != "" and v_merge != "restart" do
      # This is a merged cell continuation, skip it
      nil
    else
      # Parse cell content (paragraphs)
      content =
        tc_elem
        |> xpath(~x".//w:p"el |> add_namespace("w", @w_ns))
        |> Enum.map(&parse_paragraph/1)
        |> Enum.join("")

      # Build cell attributes
      attrs = if colspan > 1, do: ~s( colspan="#{colspan}"), else: ""

      ~s(<td class="border border-gray-300 px-3 py-2"#{attrs}>#{content}</td>)
    end
  end
end
