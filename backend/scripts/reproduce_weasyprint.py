# Minimal script to reproduce WeasyPrint HTML.write_pdf behavior
# Run from repository root: python3 backend/scripts/reproduce_weasyprint.py

from weasyprint import HTML

HTML_CONTENT = """
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Test PDF</title></head>
  <body>
    <h1>Test PDF</h1>
    <p>Testing WeasyPrint write_pdf()</p>
  </body>
</html>
"""

if __name__ == '__main__':
    try:
        pdf_bytes = HTML(string=HTML_CONTENT).write_pdf()
        print('write_pdf succeeded, produced', len(pdf_bytes), 'bytes')
    except Exception as e:
        print('write_pdf raised exception:')
        import traceback
        traceback.print_exc()
        raise
