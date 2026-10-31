#!/bin/sh
set -e
cd "$(dirname "$0")"

find diagrams/puml -type f -name '*.puml' -print | while IFS= read -r source; do
  name=$(basename "$source" .puml)
  echo "Generating $name.png from $source"
  plantuml -tpng "$source" -o "$(pwd)/Figures"
done
find diagrams/mmd -type f -name '*.mmd' -print | while IFS= read -r source; do
  name=$(basename "$source" .mmd)
  echo "Generating $name.png from $source"
  mmdc -i "$source" -o "Figures/$name.png" -b white
done
pdflatex -interaction=nonstopmode uet_thesis.tex
bibtex uet_thesis
pdflatex -interaction=nonstopmode uet_thesis.tex
pdflatex -interaction=nonstopmode uet_thesis.tex