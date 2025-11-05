# Docxir Quick Start Guide

## Installation

1. **Add to dependencies:**
   ```elixir
   # mix.exs
   def deps do
     [
       {:docxir, path: "../docxir"}  # or from Hex when published
     ]
   end
   ```

2. **Install dependencies:**
   ```bash
   mix deps.get
   ```

## Usage

### Command Line (Mix Task)

```bash
# Basic conversion
mix docxir input.docx output.html

# With options
mix docxir contract.docx contract.html --title "Rental Agreement" --lang en
```

### In Your Elixir Code

```elixir
# Tuple-returning version (safe)
case Docxir.convert("input.docx", "output.html") do
  {:ok, path} ->
    IO.puts("✓ Converted successfully to #{path}")
  {:error, :enoent} ->
    IO.puts("✗ File not found")
  {:error, reason} ->
    IO.puts("✗ Error: #{inspect(reason)}")
end

# Bang version (raises on error)
output = Docxir.convert!("input.docx", "output.html",
  title: "My Document",
  lang: "en"
)
IO.puts("Generated: #{output}")
```

## Running Tests

```bash
# All tests
mix test

# With coverage
mix test --cover

# Specific module
mix test test/docxir/parser_test.exs
```

## Generate Documentation

```bash
mix docs
open doc/index.html
```

## Project Structure

```
docxir/
├── lib/
│   ├── docxir.ex              # Main API
│   ├── docxir/
│   │   ├── xml_extractor.ex   # ZIP extraction
│   │   ├── parser.ex          # XML → HTML parsing
│   │   ├── style_mapper.ex    # Word → Tailwind CSS
│   │   ├── span_merger.ex     # HTML optimization
│   │   └── html_builder.ex    # HTML generation
│   └── mix/tasks/docxir.ex    # CLI task
├── test/                      # Comprehensive tests
└── README.md                  # Full documentation
```

## Features

✅ Standard Tailwind classes only
✅ Paragraphs (alignment, indentation, spacing)
✅ Text formatting (bold, italic, underline, font sizes)
✅ Tables with colspan
✅ Page breaks (manual and paragraph-level)
✅ Automatic span merging
✅ Both API and CLI interfaces
✅ Comprehensive tests (76 tests)
✅ Full English documentation

## Example Output

Input: Microsoft Word document with formatting
Output: Clean HTML with Tailwind CSS

```html
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <title>Document</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="max-w-4xl mx-auto p-8 bg-gray-50">
    <div class="bg-white shadow-lg rounded-lg p-8">
        <div class="mb-2"><div class="inline-block font-bold text-2xl">Title</div></div>
        <div class="mb-2 text-justify ml-6">Indented paragraph...</div>
        <!-- Clean, semantic HTML with inline-block divs for styled text -->
    </div>
</body>
</html>
```

## Performance

Sample conversion (47KB DOCX → 85KB HTML):
- Conversion time: < 100ms
- Output size: Optimized with span merging
- Memory usage: Minimal (streaming ZIP extraction)

## Next Steps

- Review the [README.md](README.md) for detailed documentation
- Check the [tests](test/) for usage examples
- Read the generated docs: `mix docs && open doc/index.html`
- Try converting your own DOCX files!
