defmodule Docxir.StyleMapperTest do
  use ExUnit.Case, async: true
  alias Docxir.StyleMapper
  doctest Docxir.StyleMapper

  describe "font_size_class/1" do
    test "returns text-base for nil" do
      assert StyleMapper.font_size_class(nil) == "text-base"
    end

    test "converts small font sizes" do
      assert StyleMapper.font_size_class(20) == "text-xs"  # 10pt
      assert StyleMapper.font_size_class(22) == "text-sm"  # 11pt
    end

    test "converts medium font sizes" do
      assert StyleMapper.font_size_class(24) == "text-sm"   # 12pt
      assert StyleMapper.font_size_class(28) == "text-base" # 14pt
    end

    test "converts large font sizes" do
      assert StyleMapper.font_size_class(32) == "text-lg"   # 16pt
      assert StyleMapper.font_size_class(36) == "text-xl"   # 18pt
      assert StyleMapper.font_size_class(48) == "text-2xl"  # 24pt
      assert StyleMapper.font_size_class(60) == "text-3xl"  # 30pt
    end

    test "accepts string input" do
      assert StyleMapper.font_size_class("24") == "text-sm"
      assert StyleMapper.font_size_class("48") == "text-2xl"
    end
  end

  describe "alignment_class/1" do
    test "returns text-left for nil" do
      assert StyleMapper.alignment_class(nil) == "text-left"
    end

    test "converts alignment values" do
      assert StyleMapper.alignment_class("left") == "text-left"
      assert StyleMapper.alignment_class("center") == "text-center"
      assert StyleMapper.alignment_class("right") == "text-right"
      assert StyleMapper.alignment_class("both") == "text-justify"
    end

    test "returns text-left for unknown values" do
      assert StyleMapper.alignment_class("unknown") == "text-left"
    end
  end

  describe "indent_class/1" do
    test "returns empty string for nil" do
      assert StyleMapper.indent_class(nil) == ""
    end

    test "returns empty string for empty string" do
      assert StyleMapper.indent_class("") == ""
    end

    test "returns empty string for small indents" do
      assert StyleMapper.indent_class(100) == ""
    end

    test "converts indent values to margin classes" do
      assert StyleMapper.indent_class(360) == "ml-4"   # ~1.5 chars
      assert StyleMapper.indent_class(720) == "ml-6"   # ~3 chars
      assert StyleMapper.indent_class(1200) == "ml-8"  # ~5 chars
      assert StyleMapper.indent_class(1800) == "ml-12" # ~7.5 chars
    end

    test "accepts string input" do
      assert StyleMapper.indent_class("360") == "ml-4"
      assert StyleMapper.indent_class("720") == "ml-6"
    end

    test "handles invalid string input gracefully" do
      assert StyleMapper.indent_class("invalid") == ""
    end
  end
end
