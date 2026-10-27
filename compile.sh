#!/bin/sh
set -e
cd "$(dirname "$0")"
pdflatex -interaction=nonstopmode uet_thesis.tex
bibtex uet_thesis
pdflatex -interaction=nonstopmode uet_thesis.tex
pdflatex -interaction=nonstopmode uet_thesis.tex
rm -f uet_thesis.aux uet_thesis.bbl uet_thesis.blg uet_thesis.log \
  uet_thesis.out uet_thesis.synctex.gz