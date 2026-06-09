---
name: read-pdf
description: >-
  Extracts and analyzes text, tables, and metadata from PDF documents using
  Python tooling. Use when the user asks to read, summarize, search, quote,
  or analyze PDF files, or when working with .pdf documents in the project.
---

# Read PDF

The Read tool does not support PDF files. Always extract content with the script below before answering questions about a PDF.

## Quick start

1. Confirm the PDF path (absolute or relative to workspace root).
2. Run extraction:

```bash
python .cursor/skills/read-pdf/scripts/extract_pdf.py path/to/file.pdf
```

3. Read the output. For long PDFs, extract a page range first:

```bash
python .cursor/skills/read-pdf/scripts/extract_pdf.py file.pdf --start 1 --end 10
```

4. Answer the user's question using extracted text. Cite page numbers when quoting.

## Dependencies

Install once per environment:

```bash
pip install pymupdf
```

For scanned/image-only PDFs, also install:

```bash
pip install pytesseract pdf2image pillow
```

Tesseract OCR must be on PATH ([install guide](https://github.com/tesseract-ocr/tesseract)).

## Decision workflow

```
User mentions a PDF
    │
    ├─ Text extraction returns content → analyze and respond
    │
    ├─ Little or no text per page → re-run with --ocr
    │
    └─ Tables needed → re-run with --tables (uses pdfplumber)
```

## Script options

| Flag | Purpose |
|------|---------|
| `--start N` | First page (1-based) |
| `--end N` | Last page (inclusive) |
| `--ocr` | OCR for scanned pages |
| `--tables` | Extract tables (requires `pdfplumber`) |
| `--json` | Machine-readable output with per-page text |
| `--metadata` | Print title, author, page count only |

## Output format

When summarizing or reporting findings, use:

```markdown
# [Document title or filename]

## Overview
[1-2 sentences: what the document is and its scope]

## Key content
- [Finding] (p. N)
- [Finding] (p. N)

## Details
[Section-by-section notes with page citations]

## Open questions
[Ambiguities or missing pages, if any]
```

## Large documents

- Extract metadata first: `--metadata`
- Work in chunks of 10–20 pages to stay within context limits
- For search tasks ("find where X is mentioned"), grep the extracted text or use `--json` and search programmatically
- Do not claim you read a PDF without running extraction

## Tables

When the user needs tabular data:

```bash
pip install pdfplumber
python .cursor/skills/read-pdf/scripts/extract_pdf.py file.pdf --tables
```

Present tables in markdown. Note when layout may have shifted columns.

## Errors

| Error | Action |
|-------|--------|
| `No module named 'fitz'` | `pip install pymupdf` |
| Empty text, no `--ocr` | Re-run with `--ocr` |
| Password-protected PDF | Ask user for password or an unlocked copy |
| Corrupt file | Report the error; ask for a re-exported PDF |

## Additional resources

- Script implementation: [scripts/extract_pdf.py](scripts/extract_pdf.py)
