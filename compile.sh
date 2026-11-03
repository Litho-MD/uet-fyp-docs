#!/bin/sh
set -e
cd "$(dirname "$0")"

mkdir -p Figures

if [ -d diagrams/puml ]; then
  if ! command -v plantuml >/dev/null 2>&1; then
    echo "Error: PlantUML is required to render diagrams/puml/*.puml." >&2
    exit 1
  fi
  find diagrams/puml -type f -name '*.puml' -print | while IFS= read -r source; do
    name=$(basename "$source" .puml)
    echo "Generating $name.png from $source"
    plantuml -tpng "$source" -o "$(pwd)/Figures"
  done
fi

if [ -d diagrams/mmd ]; then
  if command -v mmdc >/dev/null 2>&1; then
    render_mermaid() {
      mmdc "$@"
    }
  elif command -v npx >/dev/null 2>&1; then
    render_mermaid() {
      npx --yes @mermaid-js/mermaid-cli "$@"
    }
  else
    echo "Error: Mermaid CLI is required to render diagrams/mmd/*.mmd." >&2
    echo "Install mmdc or Node.js/npm so the script can use npx." >&2
    exit 1
  fi

  find diagrams/mmd -type f -name '*.mmd' -print | while IFS= read -r source; do
    name=$(basename "$source" .mmd)
    echo "Generating $name.png from $source"
    render_mermaid -i "$source" -o "Figures/$name.png" -b white
  done
fi

for command in pdflatex bibtex; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Error: $command is required to compile the thesis." >&2
    exit 1
  fi
done

pdflatex -interaction=nonstopmode uet_thesis.tex
bibtex uet_thesis
pdflatex -interaction=nonstopmode uet_thesis.tex
pdflatex -interaction=nonstopmode uet_thesis.tex