defmodule Docxir.ParserPageBreakTest do
  use ExUnit.Case, async: true
  alias Docxir.Parser

  @w_ns "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

  describe "parse/1 with page breaks" do
    test "parses paragraph with pageBreakBefore" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="#{@w_ns}">
        <w:body>
          <w:p>
            <w:pPr>
              <w:pageBreakBefore/>
            </w:pPr>
            <w:r>
              <w:t>Text after page break</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(class="mb-2 break-before-page")
      assert result =~ "Text after page break"
    end

    test "parses run with manual page break" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="#{@w_ns}">
        <w:body>
          <w:p>
            <w:r>
              <w:br w:type="page"/>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(<div class="break-after-page"></div>)
    end

    test "parses text before and after page break" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="#{@w_ns}">
        <w:body>
          <w:p>
            <w:r>
              <w:t>Before break</w:t>
            </w:r>
            <w:r>
              <w:br w:type="page"/>
            </w:r>
            <w:r>
              <w:t>After break</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ "Before break"
      assert result =~ ~s(<div class="break-after-page"></div>)
      assert result =~ "After break"

      # Ensure proper order
      assert String.contains?(result, "Before break<div class=\"break-after-page\"></div>After break")
    end

    test "parses paragraph with both pageBreakBefore and alignment" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="#{@w_ns}">
        <w:body>
          <w:p>
            <w:pPr>
              <w:pageBreakBefore/>
              <w:jc w:val="center"/>
            </w:pPr>
            <w:r>
              <w:t>Centered text on new page</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(class="mb-2 break-before-page text-center")
      assert result =~ "Centered text on new page"
    end

    test "does not add page break for regular line breaks" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="#{@w_ns}">
        <w:body>
          <w:p>
            <w:r>
              <w:t>Line 1</w:t>
            </w:r>
            <w:r>
              <w:br/>
            </w:r>
            <w:r>
              <w:t>Line 2</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ "Line 1"
      assert result =~ "Line 2"
      refute result =~ "break-after-page"
    end

    test "parses multiple paragraphs with mixed page breaks" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="#{@w_ns}">
        <w:body>
          <w:p>
            <w:r>
              <w:t>Paragraph 1</w:t>
            </w:r>
          </w:p>
          <w:p>
            <w:pPr>
              <w:pageBreakBefore/>
            </w:pPr>
            <w:r>
              <w:t>Paragraph 2 - new page via property</w:t>
            </w:r>
          </w:p>
          <w:p>
            <w:r>
              <w:t>Paragraph 3 start</w:t>
            </w:r>
            <w:r>
              <w:br w:type="page"/>
            </w:r>
            <w:r>
              <w:t>Paragraph 3 continuation after manual break</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)

      # Check all content is present
      assert result =~ "Paragraph 1"
      assert result =~ "Paragraph 2 - new page via property"
      assert result =~ "Paragraph 3 start"
      assert result =~ "Paragraph 3 continuation after manual break"

      # Check page break classes/elements
      assert result =~ ~s(class="mb-2 break-before-page")
      assert result =~ ~s(<div class="break-after-page"></div>)
    end

    test "parses page break in table cell" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="#{@w_ns}">
        <w:body>
          <w:tbl>
            <w:tr>
              <w:tc>
                <w:p>
                  <w:r>
                    <w:t>Cell content before</w:t>
                  </w:r>
                  <w:r>
                    <w:br w:type="page"/>
                  </w:r>
                  <w:r>
                    <w:t>Cell content after</w:t>
                  </w:r>
                </w:p>
              </w:tc>
            </w:tr>
          </w:tbl>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ "Cell content before"
      assert result =~ ~s(<div class="break-after-page"></div>)
      assert result =~ "Cell content after"
      assert result =~ "<table"
    end
  end
end
