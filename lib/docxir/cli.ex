defmodule Docxir.CLI do
  @moduledoc """
  Command-line interface entry point for the escript executable.
  """

  @doc """
  Main entry point for the escript.
  """
  def main(args) do
    # Ensure all applications are started
    {:ok, _} = Application.ensure_all_started(:sweet_xml)
    {:ok, _} = Application.ensure_all_started(:docxir)

    # Parse arguments
    {opts, files, invalid} = OptionParser.parse(args, switches: [
      title: :string,
      lang: :string,
      help: :boolean
    ])

    cond do
      opts[:help] ->
        print_usage()
        System.halt(0)

      invalid != [] ->
        invalid_opts = Enum.map(invalid, &elem(&1, 0)) |> Enum.join(", ")
        IO.puts(:stderr, "Invalid options: #{invalid_opts}")
        print_usage()
        System.halt(1)

      length(files) < 2 ->
        IO.puts(:stderr, "Error: Missing required arguments")
        print_usage()
        System.halt(1)

      length(files) > 2 ->
        IO.puts(:stderr, "Error: Too many arguments")
        print_usage()
        System.halt(1)

      true ->
        [input_file, output_file] = files
        perform_conversion(input_file, output_file, opts)
    end
  end

  defp perform_conversion(input_file, output_file, opts) do
    IO.puts("Converting #{input_file}...")

    case Docxir.convert(input_file, output_file, opts) do
      {:ok, path} ->
        file_size = File.stat!(path).size
        IO.puts("✓ Conversion complete!")
        IO.puts("  Output: #{path} (#{format_bytes(file_size)})")
        System.halt(0)

      {:error, :enoent} ->
        IO.puts(:stderr, "✗ Error: File '#{input_file}' not found")
        System.halt(1)

      {:error, :document_xml_not_found} ->
        IO.puts(:stderr, "✗ Error: Invalid DOCX file (document.xml not found)")
        System.halt(1)

      {:error, reason} ->
        IO.puts(:stderr, "✗ Conversion failed: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp print_usage do
    IO.puts("""

    Docxir - Convert DOCX files to HTML with Tailwind CSS

    Usage: docxir INPUT_FILE OUTPUT_FILE [OPTIONS]

    Arguments:
      INPUT_FILE   Path to the input DOCX file
      OUTPUT_FILE  Path where the HTML file should be written

    Options:
      --title TITLE  Set the document title (default: "Document")
      --lang LANG    Set the HTML language code (default: "zh-TW")
      --help         Show this help message

    Examples:
      docxir contract.docx contract.html
      docxir contract.docx output.html --title "Rental Agreement"
      docxir document.docx output.html --lang en --title "My Document"
    """)
  end

  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} bytes"
  defp format_bytes(bytes) when bytes < 1024 * 1024, do: "#{div(bytes, 1024)} KB"

  defp format_bytes(bytes),
    do: "#{Float.round(bytes / 1024 / 1024, 2)} MB"
end
