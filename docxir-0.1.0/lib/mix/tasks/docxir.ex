defmodule Mix.Tasks.Docxir do
  @moduledoc """
  Converts DOCX files to HTML with Tailwind CSS styling.

  ## Usage

      mix docxir INPUT_FILE OUTPUT_FILE [OPTIONS]

  ## Arguments

    * `INPUT_FILE` - Path to the input DOCX file
    * `OUTPUT_FILE` - Path where the HTML file should be written

  ## Options

    * `--title TITLE` - Set the document title (default: "Document")
    * `--lang LANG` - Set the HTML language code (default: "zh-TW")

  ## Examples

      # Basic conversion
      mix docxir contract.docx contract.html

      # With custom title
      mix docxir contract.docx output.html --title "Rental Agreement"

      # With custom language
      mix docxir document.docx output.html --lang en --title "My Document"

  """

  use Mix.Task

  @shortdoc "Converts DOCX to HTML with Tailwind CSS"

  @switches [
    title: :string,
    lang: :string
  ]

  @spec run([binary()]) :: :ok | no_return()
  @impl Mix.Task
  def run(args) do
    {opts, files, invalid} = OptionParser.parse(args, switches: @switches)

    cond do
      invalid != [] ->
        invalid_opts = Enum.map(invalid, &elem(&1, 0)) |> Enum.join(", ")
        Mix.shell().error("Invalid options: #{invalid_opts}")
        print_usage()
        exit({:shutdown, 1})

      length(files) < 2 ->
        Mix.shell().error("Error: Missing required arguments")
        print_usage()
        exit({:shutdown, 1})

      length(files) > 2 ->
        Mix.shell().error("Error: Too many arguments")
        print_usage()
        exit({:shutdown, 1})

      true ->
        [input_file, output_file] = files
        perform_conversion(input_file, output_file, opts)
    end
  end

  defp perform_conversion(input_file, output_file, opts) do
    # Ensure the application is started
    Mix.Task.run("app.start")

    Mix.shell().info("Converting #{input_file}...")

    case Docxir.convert(input_file, output_file, opts) do
      {:ok, path} ->
        file_size = File.stat!(path).size
        Mix.shell().info("✓ Conversion complete!")
        Mix.shell().info("  Output: #{path} (#{format_bytes(file_size)})")

      {:error, :enoent} ->
        Mix.shell().error("✗ Error: File '#{input_file}' not found")
        exit({:shutdown, 1})

      {:error, :document_xml_not_found} ->
        Mix.shell().error("✗ Error: Invalid DOCX file (document.xml not found)")
        exit({:shutdown, 1})

      {:error, reason} ->
        Mix.shell().error("✗ Conversion failed: #{inspect(reason)}")
        exit({:shutdown, 1})
    end
  end

  defp print_usage do
    Mix.shell().info("""

    Usage: mix docxir INPUT_FILE OUTPUT_FILE [OPTIONS]

    Arguments:
      INPUT_FILE   Path to the input DOCX file
      OUTPUT_FILE  Path where the HTML file should be written

    Options:
      --title TITLE  Set the document title (default: "Document")
      --lang LANG    Set the HTML language code (default: "zh-TW")

    Examples:
      mix docxir contract.docx contract.html
      mix docxir contract.docx output.html --title "Rental Agreement"
    """)
  end

  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} bytes"
  defp format_bytes(bytes) when bytes < 1024 * 1024, do: "#{div(bytes, 1024)} KB"

  defp format_bytes(bytes),
    do: "#{Float.round(bytes / 1024 / 1024, 2)} MB"
end
