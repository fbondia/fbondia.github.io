# fbondia.github.io

Personal multilingual résumé published with Jekyll and GitHub Pages.

## Generate PDF resumes

The PDF files are generated from the same Jekyll pages used by the online resumes.

```bash
./scripts/generate-resume-pdf.sh all
./scripts/generate-resume-pdf.sh en
./scripts/generate-resume-pdf.sh pt
```

By default, the files are written to `output/pdf/resume-en.pdf` and
`output/pdf/resume-pt.pdf`. An alternative output directory can be supplied as
the second argument.

The script requires Ruby dependencies installed with Bundler, Python 3, and a
Chrome-compatible browser. Set `CHROME_BIN` if the browser is not installed in
one of the standard locations.

## Generate Word resumes

The Word files use the same multilingual YAML data as the website and PDFs.

```bash
./scripts/generate-resume-docx.sh all
./scripts/generate-resume-docx.sh en
./scripts/generate-resume-docx.sh pt
```

By default, the files are written to `output/docx/resume-en.docx` and
`output/docx/resume-pt.docx`. An alternative output directory can be supplied
as the second argument. Set `DOCX_PYTHON` to a Python runtime containing
`python-docx` and Pillow when the bundled Codex runtime is unavailable.
