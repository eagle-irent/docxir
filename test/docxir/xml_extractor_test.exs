defmodule Docxir.XmlExtractorTest do
  use ExUnit.Case, async: true
  alias Docxir.XmlExtractor

  @fixtures_dir Path.join([__DIR__, "..", "fixtures"])

  describe "extract/1" do
    test "returns error for non-existent file" do
      assert {:error, :enoent} = XmlExtractor.extract("nonexistent.docx")
    end

    test "accepts binary path" do
      path = "nonexistent.docx"
      assert {:error, :enoent} = XmlExtractor.extract(path)
    end

    test "accepts charlist path" do
      path = 'nonexistent.docx'
      assert {:error, :enoent} = XmlExtractor.extract(path)
    end

    # Note: This test requires a real DOCX file in test/fixtures/
    @tag :skip
    test "extracts XML from valid DOCX file" do
      fixture_path = Path.join(@fixtures_dir, "sample.docx")

      case XmlExtractor.extract(fixture_path) do
        {:ok, xml_content} ->
          assert is_binary(xml_content)
          assert xml_content =~ "<?xml"
          assert xml_content =~ "w:document"

        {:error, :enoent} ->
          # Skip if fixture not present
          :ok
      end
    end
  end

  describe "extract!/1" do
    test "raises File.Error for non-existent file" do
      assert_raise File.Error, fn ->
        XmlExtractor.extract!("nonexistent.docx")
      end
    end

    test "raises on invalid DOCX (missing document.xml)" do
      # Create a minimal ZIP file without document.xml
      temp_path = Path.join(System.tmp_dir!(), "invalid.docx")

      File.write!(temp_path, <<80, 75, 5, 6>> <> String.duplicate(<<0>>, 18))

      assert_raise RuntimeError, ~r/Failed to extract XML/, fn ->
        XmlExtractor.extract!(temp_path)
      end

      File.rm(temp_path)
    end
  end
end
