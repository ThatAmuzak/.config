import argparse
import sys
from pathlib import Path

import deepdoctection as dd


def get_analyzer():
    """
    Build / cache a deepdoctection analyzer. The analyzer initialization
    may download models on first run, so keep a single instance.
    """
    # dd.get_dd_analyzer() returns a ready-to-use analyzer (default demo config).
    # You can customize this if you want different models/configs.
    return dd.get_dd_analyzer()


def extract_pdf_to_txt(analyzer, pdf_path: Path, txt_path: Path) -> None:
    try:
        # analyzer.analyze returns a DataFlow-like iterable of "page" objects
        df = analyzer.analyze(path=str(pdf_path))
        # ensure initialization
        try:
            df.reset_state()
        except Exception:
            # Not all DataFlow implementations need reset_state; ignore if not present
            pass

        pages_text = []
        # iterate over pages produced by the analyzer
        for page in df:
            # `page.text` is the textual content for that page (per deepdoctection API).
            # it may be None or empty; handle gracefully
            text = getattr(page, "text", None)
            if text:
                pages_text.append(text)

        content = "\n\n".join(pages_text)
        txt_path.write_text(content, encoding="utf-8")
        print(f"OK: {pdf_path.name} -> {txt_path.name}")
    except Exception as e:
        print(f"ERROR processing {pdf_path.name}: {e}", file=sys.stderr)


def main(parent_dir: str, skip_existing: bool = False, analyzer=None):
    parent = Path(parent_dir).expanduser().resolve()
    pdf_dir = parent / "pdfs"
    txt_dir = parent / "txts"

    if not pdf_dir.is_dir():
        print(f"Missing directory: {pdf_dir}", file=sys.stderr)
        sys.exit(1)

    txt_dir.mkdir(parents=True, exist_ok=True)

    pdf_files = sorted(
        p for p in pdf_dir.iterdir() if p.is_file() and p.suffix.lower() == ".pdf"
    )
    if not pdf_files:
        print("No PDF files found. Nothing to do.")
        return

    if analyzer is None:
        analyzer = get_analyzer()

    for pdf in pdf_files:
        target = txt_dir / pdf.with_suffix(".txt").name
        if skip_existing and target.exists():
            print(f"Skipping (exists): {target.name}")
            continue
        extract_pdf_to_txt(analyzer, pdf, target)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="Convert PDFs in <parent>/pdfs -> text files in <parent>/txts using deepdoctection"
    )
    ap.add_argument(
        "parent_folder", help="Parent folder that contains 'pdfs' and 'txts' subfolders"
    )
    ap.add_argument(
        "--skip-existing",
        action="store_true",
        help="Do not overwrite existing .txt files",
    )
    args = ap.parse_args()
    main(args.parent_folder, skip_existing=args.skip_existing)
