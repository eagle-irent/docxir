defmodule Docxir.XmlExtractor do
  @moduledoc """
  Extracts XML content from DOCX files.

  DOCX files are ZIP archives containing XML documents. This module
  handles the extraction of the main document XML from the archive.
  """

  @doc """
  Extracts the document.xml content from a DOCX file.

  ## Parameters

    * `docx_path` - Path to the DOCX file as a string or charlist

  ## Returns

    * `{:ok, xml_content}` - The XML content as a binary
    * `{:error, reason}` - Error tuple with reason

  ## Examples

      iex> Docxir.XmlExtractor.extract("contract.docx")
      {:ok, "<?xml version=\\"1.0\\"..."}

      iex> Docxir.XmlExtractor.extract("nonexistent.docx")
      {:error, :enoent}

  """
  @spec extract(Path.t()) :: {:ok, binary()} | {:error, atom()}
  def extract(docx_path) when is_binary(docx_path) do
    extract(String.to_charlist(docx_path))
  end

  def extract(docx_path) when is_list(docx_path) do
    with {:ok, file_list} <- :zip.unzip(docx_path, [:memory]),
         {:ok, xml_content} <- find_document_xml(file_list) do
      {:ok, xml_content}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Extracts the document.xml content from a DOCX file, raising on error.

  ## Parameters

    * `docx_path` - Path to the DOCX file

  ## Returns

    * The XML content as a binary

  ## Raises

    * `File.Error` if the file cannot be read or is not a valid DOCX

  ## Examples

      iex> Docxir.XmlExtractor.extract!("contract.docx")
      "<?xml version=\\"1.0\\"..."

  """
  @spec extract!(Path.t()) :: binary()
  def extract!(docx_path) do
    case extract(docx_path) do
      {:ok, xml_content} ->
        xml_content

      {:error, :enoent} ->
        raise File.Error, reason: :enoent, action: "read", path: to_string(docx_path)

      {:error, reason} ->
        raise "Failed to extract XML from DOCX: #{inspect(reason)}"
    end
  end

  # Private helper to find document.xml in the file list
  defp find_document_xml(file_list) do
    case Enum.find(file_list, fn {name, _content} ->
           name == ~c"word/document.xml"
         end) do
      {_name, content} -> {:ok, content}
      nil -> {:error, :document_xml_not_found}
    end
  end
end
