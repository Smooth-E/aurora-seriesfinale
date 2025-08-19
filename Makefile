##########################################################################
#    Makefile for SeriesFinale
#
#    This is a helper Makefile to build the Python translation files
#    since that is not automatically done with QtCreator.
#
#    Dependencies:
#    - lconvert: a language file conversion tool that comes with
#                the Qt distribution
#    - pybabel: a Python tool for managing gettext translations,
#               https://pypi.org/project/babel
#    - msgfmt: a tool for compiling gettext translations from .po to .mo,
#              comes with the gettext distribution
#
#    Installing dependencies in Aurora SDK:
#    - zypper in gettext python3 python3-pip && pip install babel
##########################################################################

TSFILES = $(wildcard translations/python-messages-*.ts)
POFILES = $(patsubst translations/python-messages-%.ts,translations/%/LC_MESSAGES/python-messages.po, $(TSFILES))
TSFAKES = $(patsubst translations/python-messages-%.ts,translations/python-messages-%-fake.ts, $(TSFILES))
LOCALEDIR = src/SeriesFinale/locale
MOFILES = $(patsubst translations/%/LC_MESSAGES/python-messages.po,$(LOCALEDIR)/%/LC_MESSAGES/seriesfinale.mo, $(POFILES))

LCONVERT = lconvert
PYBABEL = pybabel
MSGFMT = msgfmt

.PHONY: help clean

help:
	@echo ""
	@echo "  ** Manage Python translations **"
	@echo ""
	@echo "  make update         Update translation catalogs for translating"
	@echo "  make translations   Convert and build Python translation files"
	@echo "  make clean          Remove generated and compiled files"
	@echo ""
	@echo "  Note: Qt translations are built automatically when building the app"
	@echo ""

translations: $(MOFILES)

translations/%/LC_MESSAGES/python-messages.po: translations/python-messages-%.ts
	@mkdir -p $(@D)
	$(LCONVERT) $< -o $@

$(LOCALEDIR)/%/LC_MESSAGES/seriesfinale.mo: translations/%/LC_MESSAGES/python-messages.po
	@mkdir -p $(@D)
	$(MSGFMT) $< -o $@
	@rm -r $(subst LC_MESSAGES/python-messages.po,,$<)

update-pot:
	$(PYBABEL) extract \
		--project "harbour-seriesfinale" \
		--copyright-holder "harbour-seriesfinale contributors" \
		-c "TRANSLATORS" --no-wrap \
		src/SeriesFinale/series.py \
		-o translations/python-messages.pot

translations/python-messages-%-fake.ts: translations/%/LC_MESSAGES/python-messages.po
	$(LCONVERT) $< -o $(subst -fake.ts,.ts,$@) \
		-target-language $(subst -fake.ts,,$(subst translations/python-messages-,,$@)) \
		-no-obsolete -locations absolute
	@rm -r $(subst LC_MESSAGES/python-messages.po,,$<)

update-po: update-pot $(POFILES)
	$(PYBABEL) update --no-wrap -D python-messages -i translations/python-messages.pot -d translations

update: update-po $(TSFAKES)
	$(LCONVERT) translations/python-messages.pot -o translations/python-messages.ts -drop-translations

clean:
	rm -f $(POFILES)
	rm -rf build $(LOCALEDIR)
