# Docxir

[![Hex.pm](https://img.shields.io/hexpm/v/docxir.svg)](https://hex.pm/packages/docxir)
[![Documentation](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/docxir)

A lightweight DOCX to HTML converter with Tailwind CSS styling for Elixir.

Docxir converts Microsoft Word documents (.docx) into clean HTML documents styled with standard Tailwind CSS utility classes. It preserves basic formatting while using only standard Tailwind classes (no JIT dynamic classes).

## Features

- ✅ **Simple API**: Both tuple-returning and bang versions
- ✅ **Paragraph formatting**: Alignment, indentation, and spacing
- ✅ **Text styling**: Bold, italic, underline, and font sizes
- ✅ **Table support**: Basic tables with colspan
- ✅ **Page breaks**: Both manual and paragraph-level page breaks
- ✅ **Standard Tailwind classes**: Only uses standard utility classes (e.g., `text-lg`, `ml-4`)
- ✅ **Automatic optimization**: Merges adjacent spans with identical styles
- ✅ **CLI support**: Mix task for command-line usage

## Installation

### As a Library (Elixir Project)

Add `docxir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:docxir, "~> 0.1.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

### As a Standalone CLI Tool (Escript)

If you don't have Elixir installed but want to use Docxir as a command-line tool:

1. **Requirements**: Only Erlang runtime is needed (no Elixir required)
   - Install Erlang from [erlang.org](https://www.erlang.org/downloads) or use your package manager:
     ```bash
     # macOS
     brew install erlang

     # Ubuntu/Debian
     sudo apt-get install erlang

     # Windows
     # Download from https://www.erlang.org/downloads
     ```

2. **Get the executable**:
   - Download the pre-built `docxir` executable from releases
   - Or build it yourself if you have Elixir:
     ```bash
     git clone https://github.com/eagle-irent/docxir.git
     cd docxir
     mix deps.get
     mix escript.build
     ```

3. **Install** (optional):
   ```bash
   # Linux/macOS - make it globally available
   chmod +x docxir
   sudo mv docxir /usr/local/bin/

   # Or just run it from current directory
   ./docxir input.docx output.html
   ```

## Usage

### As a Library

```elixir
# Using the tuple-returning version
case Docxir.convert("input.docx", "output.html") do
  {:ok, path} -> IO.puts("Converted to #{path}")
  {:error, reason} -> IO.puts("Error: #{reason}")
end

# Using the bang version (raises on error)
Docxir.convert!("input.docx", "output.html", title: "My Document")

# With custom options
Docxir.convert!("contract.docx", "contract.html",
  title: "Rental Agreement",
  lang: "en"
)
```

### From Command Line (Mix Task)

If you have the library installed in an Elixir project:

```bash
# Basic conversion
mix docxir input.docx output.html

# With custom title
mix docxir contract.docx contract.html --title "Rental Agreement"

# With custom language
mix docxir document.docx output.html --lang en --title "My Document"
```

### Standalone CLI (Escript)

If you're using the standalone executable:

```bash
# Show help
docxir --help

# Basic conversion
docxir input.docx output.html

# With custom title
docxir contract.docx contract.html --title "Rental Agreement"

# With custom language and title
docxir document.docx output.html --lang en --title "My Document"
```

## Options

Both the library API and CLI support the following options:

- `:title` or `--title` - Document title (default: "Document")
- `:lang` or `--lang` - HTML language code (default: "zh-TW")

## Supported Features

### Text Formatting

- **Bold** (font-weight)
- *Italic* (font-style)
- <u>Underline</u> (text-decoration)
- Font sizes (mapped to Tailwind text classes)

### Paragraph Formatting

- Alignment (left, center, right, justify)
- Indentation (mapped to Tailwind margin classes)
- Spacing (paragraph margins)

### Tables

- Basic table structure
- Colspan (horizontal cell merging)
- Border styling with Tailwind classes

### Page Breaks

- **Paragraph-level page breaks**: `<w:pageBreakBefore/>` in Word XML is converted to `break-before-page` class
- **Manual page breaks**: `<w:br w:type="page"/>` in Word XML is converted to `<div class="break-after-page"></div>`
- Works with Tailwind's print utilities for proper page breaks when printing or generating PDFs

### Tailwind Class Mapping

| Word Feature | Tailwind Classes |
|--------------|------------------|
| Font Size ≤10pt | `text-xs` |
| Font Size ≤12pt | `text-sm` |
| Font Size ≤14pt | `text-base` |
| Font Size ≤16pt | `text-lg` |
| Font Size ≤18pt | `text-xl` |
| Font Size ≤24pt | `text-2xl` |
| Font Size >24pt | `text-3xl` |
| Indent 1-2 chars | `ml-4` |
| Indent 2-4 chars | `ml-6` |
| Indent 4-6 chars | `ml-8` |
| Indent >6 chars | `ml-12` |
| Page Break Before | `break-before-page` |
| Page Break (manual) | `<div class="break-after-page"></div>` |

## Architecture

Docxir consists of several focused modules:

- **`Docxir`** - Main API module
- **`Docxir.XmlExtractor`** - Extracts XML from DOCX ZIP archives
- **`Docxir.Parser`** - Parses Word XML into HTML
- **`Docxir.StyleMapper`** - Maps Word styles to Tailwind classes
- **`Docxir.SpanMerger`** - Optimizes HTML by merging adjacent spans
- **`Docxir.HtmlBuilder`** - Generates complete HTML documents
- **`Mix.Tasks.Docxir`** - CLI task

## Limitations

This is an MVP implementation focused on common document features. The following are not currently supported:

- Images and embedded objects
- Complex table features (rowspan, nested tables)
- Advanced formatting (borders, shading, custom styles)
- Headers and footers
- Footnotes and endnotes
- Comments and track changes

## Development

### Building the Escript

To build the standalone CLI executable:

```bash
# Development build
mix escript.build

# Production build (optimized)
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix escript.build
```

This will generate a `docxir` executable file (~4.4MB) in the project root. The executable includes all dependencies and can be distributed to users who only have Erlang installed.

**Note**: The escript executable is not tracked in git. Users should either:
- Download pre-built executables from [GitHub Releases](https://github.com/eagle-irent/docxir/releases)
- Build it themselves using the commands above

### Running Tests

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test file
mix test test/docxir/parser_test.exs
```

### Generating Documentation

```bash
mix docs
```

The documentation will be generated in the `doc/` directory.

### Code Formatting

```bash
# Check formatting
mix format --check-formatted

# Auto-format code
mix format
```

## Examples

### Input (DOCX)

A Microsoft Word document with:
- Title in bold, 24pt
- Paragraphs with various alignments and indentation
- Tables with merged cells
- Text with bold, italic, and underline formatting

### Output (HTML)

```html
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document Title</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="max-w-4xl mx-auto p-8 bg-gray-50">
    <div class="bg-white shadow-lg rounded-lg p-8">
        <div class="mb-2"><div class="inline-block font-bold text-2xl">Document Title</div></div>
        <div class="mb-2 text-justify ml-6">Indented paragraph with justified text.</div>
        <table class="w-full border-collapse border border-gray-400 my-4">
            <tr>
                <td class="border border-gray-300 px-3 py-2">Cell 1</td>
                <td class="border border-gray-300 px-3 py-2">Cell 2</td>
            </tr>
        </table>
    </div>
</body>
</html>
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the Python `lxml` and `python-docx` libraries
- Uses [SweetXml](https://github.com/kbrw/sweet_xml) for XML parsing
- Styled with [Tailwind CSS](https://tailwindcss.com)
