.DEFAULT_GOAL := all 

# --- EJECT: snapshot do diretório -----------------------------
EJECT_DATETIME := $(shell date +%Y%m%d_%H%M%S)
EJECT_FILE     := tcc_snapshot_$(EJECT_DATETIME).tar.gz

.PHONY: eject
eject:
	tar -czf $(EJECT_FILE) \
		--exclude='snapshot_*.tar.gz' \
		--exclude='.git' \
		--exclude='$(ARCHIVE)' \
		.
	@echo "Snapshot criado: $(EJECT_FILE)"
# --- FIM EJECT ------------------------------------------------

PACKAGE := infufrgs
VERSION := $(shell sed -n '1{s/^Version[[:space:]]*//;p;q;}' CHANGELOG)
ARCHIVE := $(PACKAGE).tgz

DOC_SOURCE := infufrgs-doc.tex
DOC_PDF := infufrgs-doc.pdf
DOC_AUX := infufrgs-doc.aux infufrgs-doc.log infufrgs-doc.out infufrgs-doc.toc

EXAMPLE_SOURCE := infufrgs-example.tex
EXAMPLE_PDF := infufrgs-example.pdf
EXAMPLE_BASENAME := $(basename $(EXAMPLE_PDF))
EXAMPLE_AUX := infufrgs-example.aux infufrgs-example.bbl infufrgs-example.blg infufrgs-example.lof infufrgs-example.log \
	infufrgs-example.lot infufrgs-example.out infufrgs-example.toc

PDFS := $(DOC_PDF) $(EXAMPLE_PDF)
ARCHIVE_CONTENTS := $(wildcard *.tex) $(wildcard *.bib) README.md CHANGELOG COPYING \
	infufrgs.cls $(PDFS)

## Fix for tar on macOS (BSD tar) vs GNU tar. BSD tar uses -s instead of --transform.
# TAR_RENAME := $(if $(findstring GNU,$(shell tar --version)),--transform "s,^,$(PACKAGE)/,",-s ",^,$(PACKAGE)/,")
ifneq ($(findstring GNU,$(shell tar --version)),)
TAR_RENAME = --transform "s,^,$(PACKAGE)/,"
else
TAR_RENAME = -s ",^,$(PACKAGE)/,"
endif

.PHONY: all pdfs package clean

all: package

pdfs: $(PDFS)

package: pdfs
	tar -czf "$(ARCHIVE)" $(TAR_RENAME) -- $(ARCHIVE_CONTENTS)

$(DOC_PDF): $(DOC_SOURCE) infufrgs.cls
	pdflatex -interaction=nonstopmode -halt-on-error -jobname="$(basename $@)" $(DOC_SOURCE)
	pdflatex -interaction=nonstopmode -halt-on-error -jobname="$(basename $@)" $(DOC_SOURCE)

$(EXAMPLE_PDF): $(EXAMPLE_SOURCE) infufrgs-example.bib infufrgs.cls
	pdflatex -interaction=nonstopmode -halt-on-error -jobname="$(basename $@)" $(EXAMPLE_SOURCE)
	bibtex "$(EXAMPLE_BASENAME)"
	pdflatex -interaction=nonstopmode -halt-on-error -jobname="$(basename $@)" $(EXAMPLE_SOURCE)
	pdflatex -interaction=nonstopmode -halt-on-error -jobname="$(basename $@)" $(EXAMPLE_SOURCE)

clean:
	rm -f $(PDFS) $(DOC_AUX) $(EXAMPLE_AUX)
	rm -f "$(ARCHIVE)"

# --- TEMPORÁRIO: compilar apenas biblio/ (remover depois) ------------
TMP_BIB_DIR  := biblio
TMP_BIB_NAME := biblio

.PHONY: tmp-bib
tmp-bib:
	cd $(TMP_BIB_DIR) && pdflatex -interaction=nonstopmode -halt-on-error $(TMP_BIB_NAME).tex
	cd $(TMP_BIB_DIR) && bibtex $(TMP_BIB_NAME)
	cd $(TMP_BIB_DIR) && pdflatex -interaction=nonstopmode -halt-on-error $(TMP_BIB_NAME).tex
	cd $(TMP_BIB_DIR) && pdflatex -interaction=nonstopmode -halt-on-error $(TMP_BIB_NAME).tex

.PHONY: tmp-bib-clean
tmp-bib-clean:
	cd $(TMP_BIB_DIR) && rm -f *.aux *.bbl *.blg *.log *.out *.toc *.pdf
# --- FIM DO TEMPORÁRIO -----------------------------------------------