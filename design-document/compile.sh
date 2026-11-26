#!/bin/sh
set -e
cd "$(dirname "$0")"

find diagrams/puml -type f -name '*.puml' -print | while IFS= read -r source; do
  relative=${source#diagrams/puml/}
  relative_dir=$(dirname "$relative")
  output_dir="Figures/$relative_dir"
  name=$(basename "$source" .puml)
  mkdir -p "$output_dir"
  echo "Generating $output_dir/$name.png from $source"
  plantuml -tpng "$source" -o "$(pwd)/$output_dir"
done
find diagrams/mmd -type f -name '*.mmd' -print | while IFS= read -r source; do
  relative=${source#diagrams/mmd/}
  output="Figures/${relative%.mmd}.png"
  mkdir -p "$(dirname "$output")"
  echo "Generating $output from $source"
  mmdc -i "$source" -o "$output" -b white
done
find diagrams/svg -type f -name '*.svg' -print | while IFS= read -r source; do
  relative=${source#diagrams/svg/}
  output="Figures/${relative%.svg}.png"
  mkdir -p "$(dirname "$output")"
  echo "Generating $output from $source"
  rsvg-convert "$source" -o "$output"
done

pdflatex -interaction=nonstopmode uet_thesis.tex
bibtex uet_thesis
pdflatex -interaction=nonstopmode uet_thesis.tex
pdflatex -interaction=nonstopmode uet_thesis.tex