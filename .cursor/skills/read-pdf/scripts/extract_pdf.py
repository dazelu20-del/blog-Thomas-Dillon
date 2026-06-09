#!/usr/bin/env python3
"""Extract text, tables, and metadata from PDF files."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def extract_metadata(doc) -> dict:
    meta = doc.metadata or {}
    return {
        "page_count": doc.page_count,
        "title": meta.get("title") or "",
        "author": meta.get("author") or "",
        "subject": meta.get("subject") or "",
    }


def extract_text_pymupdf(path: Path, start: int, end: int, use_ocr: bool) -> list[dict]:
    import fitz

    doc = fitz.open(path)
    pages = []
    last = min(end, doc.page_count)
    first = max(1, start)

    for num in range(first, last + 1):
        page = doc[num - 1]
        text = page.get_text().strip()

        if use_ocr and len(text) < 20:
            try:
                import pytesseract
                from PIL import Image
                import io

                pix = page.get_pixmap(dpi=200)
                img = Image.open(io.BytesIO(pix.tobytes("png")))
                text = pytesseract.image_to_string(img).strip()
            except ImportError:
                sys.stderr.write(
                    "OCR requested but pytesseract/Pillow not installed.\n"
                    "Run: pip install pytesseract pillow\n"
                )
                sys.exit(1)
            except Exception as exc:
                text = f"[OCR failed: {exc}]"

        pages.append({"page": num, "text": text})

    doc.close()
    return pages


def extract_tables_pdfplumber(path: Path, start: int, end: int) -> list[dict]:
    import pdfplumber

    results = []
    with pdfplumber.open(path) as pdf:
        last = min(end, len(pdf.pages))
        first = max(1, start)
        for num in range(first, last + 1):
            page = pdf.pages[num - 1]
            tables = page.extract_tables() or []
            results.append({"page": num, "tables": tables})
    return results


def tables_to_markdown(tables: list) -> str:
    if not tables:
        return ""
    lines = []
    for i, table in enumerate(tables, 1):
        lines.append(f"### Table {i}")
        if not table:
            lines.append("(empty)")
            continue
        header = table[0]
        lines.append("| " + " | ".join(str(c or "") for c in header) + " |")
        lines.append("| " + " | ".join("---" for _ in header) + " |")
        for row in table[1:]:
            lines.append("| " + " | ".join(str(c or "") for c in row) + " |")
        lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Extract content from PDF files")
    parser.add_argument("pdf", type=Path, help="Path to PDF file")
    parser.add_argument("--start", type=int, default=1, help="First page (1-based)")
    parser.add_argument("--end", type=int, default=None, help="Last page (inclusive)")
    parser.add_argument("--ocr", action="store_true", help="OCR pages with little text")
    parser.add_argument("--tables", action="store_true", help="Extract tables via pdfplumber")
    parser.add_argument("--json", action="store_true", help="Output JSON")
    parser.add_argument("--metadata", action="store_true", help="Metadata only")
    args = parser.parse_args()

    if not args.pdf.exists():
        sys.stderr.write(f"File not found: {args.pdf}\n")
        return 1

    try:
        import fitz
    except ImportError:
        sys.stderr.write("PyMuPDF not installed. Run: pip install pymupdf\n")
        return 1

    doc = fitz.open(args.pdf)
    end = args.end or doc.page_count

    if args.metadata:
        print(json.dumps(extract_metadata(doc), indent=2))
        doc.close()
        return 0

    if args.tables:
        try:
            table_pages = extract_tables_pdfplumber(args.pdf, args.start, end)
        except ImportError:
            sys.stderr.write("pdfplumber not installed. Run: pip install pdfplumber\n")
            doc.close()
            return 1
        doc.close()
        if args.json:
            print(json.dumps(table_pages, indent=2))
        else:
            for entry in table_pages:
                print(f"## Page {entry['page']}\n")
                print(tables_to_markdown(entry["tables"]))
        return 0

    pages = extract_text_pymupdf(args.pdf, args.start, end, args.ocr)
    meta = extract_metadata(doc)
    doc.close()

    if args.json:
        print(json.dumps({"metadata": meta, "pages": pages}, indent=2))
    else:
        print(f"# {meta['title'] or args.pdf.name}")
        print(f"Pages: {meta['page_count']}")
        if meta["author"]:
            print(f"Author: {meta['author']}")
        print()
        for entry in pages:
            print(f"## Page {entry['page']}\n")
            print(entry["text"] or "(no text)")
            print()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
