defmodule Docxir.ParserTest do
  use ExUnit.Case, async: true
  alias Docxir.Parser

  describe "parse/1" do
    test "parses simple paragraph with text" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:r>
              <w:t>Hello World</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ "<div class=\"mb-2\">Hello World</div>"
    end

    test "parses paragraph with bold text" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:r>
              <w:rPr>
                <w:b/>
              </w:rPr>
              <w:t>Bold Text</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(<div class="inline-block font-bold">Bold Text</div>)
    end

    test "parses paragraph with italic text" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:r>
              <w:rPr>
                <w:i/>
              </w:rPr>
              <w:t>Italic Text</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(<div class="inline-block italic">Italic Text</div>)
    end

    test "parses paragraph with underline text" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:r>
              <w:rPr>
                <w:u w:val="single"/>
              </w:rPr>
              <w:t>Underlined</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(<div class="inline-block underline">Underlined</div>)
    end

    test "parses paragraph with font size" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:r>
              <w:rPr>
                <w:sz w:val="48"/>
              </w:rPr>
              <w:t>Large Text</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(<div class="inline-block text-2xl">Large Text</div>)
    end

    test "parses paragraph with center alignment" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:pPr>
              <w:jc w:val="center"/>
            </w:pPr>
            <w:r>
              <w:t>Centered</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(class="mb-2 text-center")
    end

    test "parses paragraph with indentation" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:pPr>
              <w:ind w:left="720"/>
            </w:pPr>
            <w:r>
              <w:t>Indented</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(class="mb-2 ml-6")
    end

    test "parses empty paragraph" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(<div class="mb-1"></div>)
    end

    test "parses simple table" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:tbl>
            <w:tr>
              <w:tc>
                <w:p>
                  <w:r>
                    <w:t>Cell 1</w:t>
                  </w:r>
                </w:p>
              </w:tc>
              <w:tc>
                <w:p>
                  <w:r>
                    <w:t>Cell 2</w:t>
                  </w:r>
                </w:p>
              </w:tc>
            </w:tr>
          </w:tbl>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(<table class="w-full border-collapse border border-gray-400 my-4">)
      assert result =~ ~s(<td class="border border-gray-300 px-3 py-2">)
      assert result =~ "Cell 1"
      assert result =~ "Cell 2"
    end

    test "parses table with colspan" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:tbl>
            <w:tr>
              <w:tc>
                <w:tcPr>
                  <w:gridSpan w:val="2"/>
                </w:tcPr>
                <w:p>
                  <w:r>
                    <w:t>Merged Cell</w:t>
                  </w:r>
                </w:p>
              </w:tc>
            </w:tr>
          </w:tbl>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      assert result =~ ~s(colspan="2")
    end

    test "merges adjacent spans with same style" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:r>
              <w:rPr><w:sz w:val="24"/></w:rPr>
              <w:t>Hello</w:t>
            </w:r>
            <w:r>
              <w:rPr><w:sz w:val="24"/></w:rPr>
              <w:t> World</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)
      # Should be merged into one inline div
      assert result =~ ~s(<div class="inline-block text-sm">Hello World</div>)
      # Should NOT contain two separate inline divs
      refute result =~ ~s(</div><div class="inline-block text-sm">)
    end
  end
end
