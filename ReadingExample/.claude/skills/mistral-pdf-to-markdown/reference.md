# Mistral PDF to Markdown - Reference Guide

Advanced usage, API details, and troubleshooting for the Mistral OCR PDF converter.

## API Details

### Mistral OCR API

The conversion uses Mistral's OCR API (`mistral-ocr-latest` model):

**Endpoint:** `https://api.mistral.ai/v1/ocr`

**Authentication:** Bearer token via `MISTRAL_API_KEY`

**Supported Formats:**
- PDF, PPTX, DOCX
- PNG, JPEG, AVIF images

### Response Structure

```python
OCRResponse
├── pages: List[OCRPageObject]
│   ├── index: int
│   ├── markdown: str
│   ├── images: List[ImageObject]
│   │   ├── id: str (e.g., "img-0.jpeg")
│   │   ├── top_left_x, top_left_y: float
│   │   ├── bottom_right_x, bottom_right_y: float
│   │   └── image_base64: str (when include_image_base64=True)
│   └── dimensions: OCRPageDimensions
│       ├── dpi: int
│       ├── height: int
│       └── width: int
├── model: str ("mistral-ocr-2505-completion")
├── usage_info: OCRUsageInfo
│   ├── pages_processed: int
│   └── doc_size_bytes: int
└── document_annotation: Optional[Any]
```

## Advanced Usage

### Programmatic Usage

```python
import sys
sys.path.append('.claude/skills/mistral-pdf-to-markdown/scripts')
from convert_pdf_to_markdown import (
    load_api_key,
    extract_pages,
    process_with_mistral,
    save_images
)

# Load API key
api_key = load_api_key()

# Extract pages
base64_pdf = extract_pages("Literature/paper.pdf", page_selection="1-5")

# Process with Mistral
ocr_response = process_with_mistral(api_key, base64_pdf)

# Custom image handling
for page_idx, page in enumerate(ocr_response.pages):
    print(f"Page {page_idx}: {len(page.images)} images")
```

### Batch Processing

```python
from pathlib import Path
import subprocess

# Process multiple PDFs
pdf_dir = Path("Literature")
output_dir = Path("Extracted")

for pdf_file in pdf_dir.glob("*.pdf"):
    output_file = output_dir / f"{pdf_file.stem}.md"

    subprocess.run([
        "python",
        ".claude/skills/mistral-pdf-to-markdown/scripts/convert_pdf_to_markdown.py",
        str(pdf_file),
        str(output_file)
    ])
```

## Troubleshooting

### Common Issues

#### 1. API Authentication Errors

**Symptom:** `401 Unauthorized` error

**Solutions:**
```bash
# Verify API key exists
grep mistral_api_key .env

# Test API key manually
export MISTRAL_API_KEY="your-key-here"
python -c "from mistralai import Mistral; print(Mistral(api_key='$MISTRAL_API_KEY'))"
```

#### 2. Large File Processing

**Symptom:** Timeout or memory errors with large PDFs

**Solutions:**
- Extract pages in chunks: `--pages "1-10"`, then `--pages "11-20"`, etc.
- Reduce PDF size before processing

## Comparison with Other Methods

| Feature | Mistral OCR | pypdf |
|---------|-------------|-------|
| Text extraction | Excellent | Good |
| Scanned PDFs | Yes (OCR) | No |
| Image extraction | Automatic | No |
| Markdown output | Native | Manual |
| Cost | API calls | Free |
| Speed | Moderate | Fast |

**Use Mistral OCR when:**
- PDF contains scanned images requiring OCR
- Need Markdown output with formatting
- Want automatic image extraction

**Use pypdf when:**
- Simple text extraction sufficient
- No OCR required
- Need faster processing
