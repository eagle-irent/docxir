defmodule Docxir.StyleMapper do
  @moduledoc """
  Maps Word document styles to Tailwind CSS classes.

  This module provides functions to convert Microsoft Word styling
  attributes (font sizes, alignment, indentation) into standard
  Tailwind CSS utility classes.

  Only standard Tailwind classes are used (no JIT dynamic classes like `text-[14px]`).
  """

  @doc """
  Converts Word font size to Tailwind text size class.

  Word uses half-points for font sizes (e.g., 24 = 12pt).

  ## Parameters

    * `sz_val` - Font size value as integer or string, or nil

  ## Returns

    * Tailwind CSS class as string

  ## Examples

      iex> Docxir.StyleMapper.font_size_class(24)
      "text-sm"

      iex> Docxir.StyleMapper.font_size_class(48)
      "text-2xl"

      iex> Docxir.StyleMapper.font_size_class(nil)
      "text-base"

  """
  @spec font_size_class(integer() | binary() | nil) :: binary()
  def font_size_class(nil), do: "text-base"

  def font_size_class(sz_val) when is_binary(sz_val) do
    sz_val
    |> String.to_integer()
    |> font_size_class()
  end

  def font_size_class(sz_val) when is_integer(sz_val) do
    # Convert half-points to points
    points = sz_val / 2

    cond do
      points <= 10 -> "text-xs"
      points <= 12 -> "text-sm"
      points <= 14 -> "text-base"
      points <= 16 -> "text-lg"
      points <= 18 -> "text-xl"
      points <= 24 -> "text-2xl"
      true -> "text-3xl"
    end
  end

  @doc """
  Converts Word alignment to Tailwind text alignment class.

  ## Parameters

    * `jc_val` - Justification value: "left", "center", "right", or "both"

  ## Returns

    * Tailwind CSS class as string

  ## Examples

      iex> Docxir.StyleMapper.alignment_class("center")
      "text-center"

      iex> Docxir.StyleMapper.alignment_class("both")
      "text-justify"

      iex> Docxir.StyleMapper.alignment_class(nil)
      "text-left"

  """
  @spec alignment_class(binary() | nil) :: binary()
  def alignment_class(nil), do: "text-left"
  def alignment_class("left"), do: "text-left"
  def alignment_class("center"), do: "text-center"
  def alignment_class("right"), do: "text-right"
  def alignment_class("both"), do: "text-justify"
  def alignment_class(_), do: "text-left"

  @doc """
  Converts Word indentation to Tailwind margin-left class.

  Word uses twips (1/1440 inch) for indentation measurements.

  ## Parameters

    * `indent_val` - Indentation value in twips as integer or string, or nil

  ## Returns

    * Tailwind CSS class as string, or empty string if no indentation

  ## Examples

      iex> Docxir.StyleMapper.indent_class(360)
      "ml-4"

      iex> Docxir.StyleMapper.indent_class(720)
      "ml-6"

      iex> Docxir.StyleMapper.indent_class(nil)
      ""

  """
  @spec indent_class(integer() | binary() | nil) :: binary()
  def indent_class(nil), do: ""
  def indent_class(""), do: ""

  def indent_class(indent_val) when is_binary(indent_val) do
    indent_val
    |> String.to_integer()
    |> indent_class()
  rescue
    ArgumentError -> ""
  end

  def indent_class(indent_val) when is_integer(indent_val) do
    # Convert twips to approximate character widths
    # 1440 twips = 1 inch ≈ 96px ≈ 6rem
    # 240 twips ≈ 1 character width
    chars = indent_val / 240

    cond do
      chars < 1 -> ""
      chars < 2 -> "ml-4"
      chars < 4 -> "ml-6"
      chars < 6 -> "ml-8"
      true -> "ml-12"
    end
  end
end
