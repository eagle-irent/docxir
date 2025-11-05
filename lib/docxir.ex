defmodule Docxir do
  @moduledoc """
  A lightweight DOCX to HTML converter with Tailwind CSS styling.

  Docxir converts Microsoft Word documents (.docx) into clean HTML documents
  styled with standard Tailwind CSS utility classes. It preserves basic
  formatting including:

  * Paragraphs with alignment and indentation
  * Text styling (bold, italic, underline, font sizes)
  * Tables with colspan support
  * Standard Tailwind classes only (no JIT dynamic classes)

  ## Usage

  The main API provides two functions for conversion:

    * `convert/3` - Returns `{:ok, output_path}` or `{:error, reason}`
    * `convert!/3` - Returns `output_path` or raises an exception

  ## Examples

      # Using the tuple-returning version
      case Docxir.convert("input.docx", "output.html") do
        {:ok, path} -> IO.puts("Converted to \#{path}")
        {:error, reason} -> IO.puts("Error: \#{reason}")
      end

      # Using the bang version
      Docxir.convert!("input.docx", "output.html", title: "My Document")

  ## Options

    * `:title` - Document title (default: "Document")
    * `:lang` - HTML language code (default: "zh-TW")

  """

  alias Docxir.{XmlExtractor, Parser, HtmlBuilder}

  @doc """
  Converts a DOCX file to HTML with Tailwind CSS styling.

  ## Parameters

    * `input_path` - Path to the input DOCX file
    * `output_path` - Path where the HTML file should be written
    * `opts` - Keyword list of options (see module documentation)

  ## Returns

    * `{:ok, output_path}` on success
    * `{:error, reason}` on failure

  ## Examples

      iex> Docxir.convert("missing.docx", "output.html")
      {:error, :enoent}

      iex> {:error, _} = Docxir.convert("nonexistent.docx", "output.html")
      iex> true
      true

  """
  @spec convert(Path.t(), Path.t(), keyword()) :: {:ok, Path.t()} | {:error, term()}
  def convert(input_path, output_path, opts \\ []) do
    with {:ok, xml_content} <- XmlExtractor.extract(input_path),
         body_html <- Parser.parse(xml_content),
         html <- HtmlBuilder.build(body_html, opts),
         :ok <- File.write(output_path, html) do
      {:ok, output_path}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Converts a DOCX file to HTML, raising on error.

  Similar to `convert/3` but raises exceptions instead of returning
  error tuples.

  ## Parameters

    * `input_path` - Path to the input DOCX file
    * `output_path` - Path where the HTML file should be written
    * `opts` - Keyword list of options (see module documentation)

  ## Returns

    * The output path on success

  ## Raises

    * `File.Error` if file operations fail
    * `RuntimeError` for other conversion errors

  """
  @spec convert!(Path.t(), Path.t(), keyword()) :: Path.t()
  def convert!(input_path, output_path, opts \\ []) do
    case convert(input_path, output_path, opts) do
      {:ok, path} ->
        path

      {:error, reason} when is_atom(reason) ->
        raise File.Error, reason: reason, action: "convert", path: input_path
    end
  end

  @doc """
  Returns the version of Docxir.

  ## Examples

      iex> Docxir.version()
      "0.1.0"

  """
  @spec version() :: binary()
  def version do
    Application.spec(:docxir, :vsn) |> to_string()
  end
end
