defmodule Docxir.ParserOrderTest do
  use ExUnit.Case, async: true
  alias Docxir.Parser

  @w_ns "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

  describe "parse/1 element ordering" do
    test "preserves order of paragraphs and tables in document" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="#{@w_ns}">
        <w:body>
          <w:p>
            <w:r>
              <w:t>Paragraph 1</w:t>
            </w:r>
          </w:p>
          <w:tbl>
            <w:tr>
              <w:tc>
                <w:p>
                  <w:r>
                    <w:t>Table Cell</w:t>
                  </w:r>
                </w:p>
              </w:tc>
            </w:tr>
          </w:tbl>
          <w:p>
            <w:r>
              <w:t>Paragraph 2</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)

      # Find the positions of each element in the output
      p1_pos = :binary.match(result, "Paragraph 1") |> elem(0)
      table_pos = :binary.match(result, "<table") |> elem(0)
      p2_pos = :binary.match(result, "Paragraph 2") |> elem(0)

      # Verify the order: Paragraph 1, then Table, then Paragraph 2
      assert p1_pos < table_pos, "Paragraph 1 should come before table"
      assert table_pos < p2_pos, "Table should come before Paragraph 2"
    end

    test "preserves order with multiple tables and paragraphs" do
      xml = """
      <?xml version="1.0"?>
      <w:document xmlns:w="#{@w_ns}">
        <w:body>
          <w:p>
            <w:r>
              <w:t>Start</w:t>
            </w:r>
          </w:p>
          <w:tbl>
            <w:tr>
              <w:tc>
                <w:p>
                  <w:r>
                    <w:t>Table 1</w:t>
                  </w:r>
                </w:p>
              </w:tc>
            </w:tr>
          </w:tbl>
          <w:p>
            <w:r>
              <w:t>Middle</w:t>
            </w:r>
          </w:p>
          <w:tbl>
            <w:tr>
              <w:tc>
                <w:p>
                  <w:r>
                    <w:t>Table 2</w:t>
                  </w:r>
                </w:p>
              </w:tc>
            </w:tr>
          </w:tbl>
          <w:p>
            <w:r>
              <w:t>End</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      """

      result = Parser.parse(xml)

      # Check the order by finding positions
      start_pos = :binary.match(result, "Start") |> elem(0)
      table1_pos = :binary.match(result, "Table 1") |> elem(0)
      middle_pos = :binary.match(result, "Middle") |> elem(0)
      table2_pos = :binary.match(result, "Table 2") |> elem(0)
      end_pos = :binary.match(result, "End") |> elem(0)

      # Verify the order: Start -> Table 1 -> Middle -> Table 2 -> End
      assert start_pos < table1_pos, "Start should come before Table 1"
      assert table1_pos < middle_pos, "Table 1 should come before Middle"
      assert middle_pos < table2_pos, "Middle should come before Table 2"
      assert table2_pos < end_pos, "Table 2 should come before End"
    end
  end
end
