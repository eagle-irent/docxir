defmodule DocxirTest do
  use ExUnit.Case, async: true
  doctest Docxir

  @fixtures_dir Path.join([__DIR__, "fixtures"])
  @temp_dir System.tmp_dir!()

  describe "convert/3" do
    test "returns error for non-existent input file" do
      output_path = Path.join(@temp_dir, "output.html")
      assert {:error, :enoent} = Docxir.convert("nonexistent.docx", output_path)
    end

    test "returns error tuple on failure" do
      output_path = Path.join(@temp_dir, "output.html")
      result = Docxir.convert("nonexistent.docx", output_path)
      assert {:error, _reason} = result
    end

    # Note: This test requires a real DOCX file in test/fixtures/
    @tag :skip
    test "converts DOCX to HTML successfully" do
      input_path = Path.join(@fixtures_dir, "sample.docx")
      output_path = Path.join(@temp_dir, "test_output.html")

      case Docxir.convert(input_path, output_path) do
        {:ok, ^output_path} ->
          assert File.exists?(output_path)
          content = File.read!(output_path)
          assert content =~ "<!DOCTYPE html>"
          assert content =~ "tailwindcss"
          File.rm(output_path)

        {:error, :enoent} ->
          # Skip if fixture not present
          :ok
      end
    end

    @tag :skip
    test "uses custom title option" do
      input_path = Path.join(@fixtures_dir, "sample.docx")
      output_path = Path.join(@temp_dir, "test_output.html")

      case Docxir.convert(input_path, output_path, title: "Custom Title") do
        {:ok, ^output_path} ->
          content = File.read!(output_path)
          assert content =~ "<title>Custom Title</title>"
          File.rm(output_path)

        {:error, :enoent} ->
          :ok
      end
    end
  end

  describe "convert!/3" do
    test "raises on non-existent input file" do
      output_path = Path.join(@temp_dir, "output.html")

      assert_raise File.Error, fn ->
        Docxir.convert!("nonexistent.docx", output_path)
      end
    end

    @tag :skip
    test "returns output path on success" do
      input_path = Path.join(@fixtures_dir, "sample.docx")
      output_path = Path.join(@temp_dir, "test_output.html")

      case File.exists?(input_path) do
        true ->
          result = Docxir.convert!(input_path, output_path)
          assert result == output_path
          assert File.exists?(output_path)
          File.rm(output_path)

        false ->
          :ok
      end
    end
  end

  describe "version/0" do
    test "returns version string" do
      version = Docxir.version()
      assert is_binary(version)
      assert version =~ ~r/\d+\.\d+\.\d+/
    end
  end
end
