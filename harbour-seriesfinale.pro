# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = moe.smoothie.seriesfinale

DEPLOYMENT_PATH = /usr/share/$${TARGET}

src.path = $${DEPLOYMENT_PATH}/src
src.files = src/*.py \
            src/SeriesFinale

CONFIG += auroraapp

SOURCES += src/moe.smoothie.seriesfinale.cpp

OTHER_FILES += qml/harbour-seriesfinale.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-seriesfinale.changes \
    rpm/harbour-seriesfinale.spec \
    rpm/harbour-seriesfinale.yaml \
    translations/*.ts \
    moe.smoothie.seriesfinale.desktop

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

INSTALLS += src

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += auroraapp_i18n

TRANSLATIONS += translations/moe.smoothie.seriesfinale-*.ts

DISTFILES += \
    qml/pages/PrioritySelectionDialog.qml \
    qml/pages/ShowInfoDialog.qml \
    qml/pages/components/OpalAboutAttribution.qml \
    qml/pages/AboutPage.qml \
    qml/pages/AddShow.qml \
    qml/pages/EpisodeListRowDelegate.qml \
    qml/pages/EpisodePage.qml \
    qml/pages/ListRowDelegate.qml \
    qml/pages/SearchSettingsPage.qml \
    qml/pages/SeasonPage.qml \
    qml/pages/SeriesPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/ShowPage.qml \
    qml/pages/*.qml \
    qml/util.js \
    src/seriesfinale.py \
    src/SeriesFinale/placeholderimage.png \
    src/SeriesFinale/asyncworker.py \
    src/SeriesFinale/__init__.py \
    src/SeriesFinale/series.py \
    src/SeriesFinale/settings.py \
    src/SeriesFinale/lib/connectionmanager.py \
    src/SeriesFinale/lib/constants.py \
    src/SeriesFinale/lib/__init__.py \
    src/SeriesFinale/lib/listmodel.py \
    src/SeriesFinale/lib/serializer.py \
    src/SeriesFinale/lib/thetvdbapi_v2.py \
    src/SeriesFinale/lib/util.py \
    qml/pages/StatisticsPage.qml \
    qml/pages/AddCalendarPage.qml \
    qml/pages/SurveyPage.qml \
    qml/pages/MyCalendarPicker.qml

# Vendor libraries

libdir = /usr/share/$$TARGET/lib
libexecdir = /usr/libexec/$$TARGET

message(Building for architecture $$QT_ARCH)
equals(QT_ARCH, arm64) {
    vendor = vendor/aarch64
    lib_subdir = lib64
}
# qmake in Aurora Platform SDK armv7hl prefix reports QT_ARCH as just arm...
equals(QT_ARCH, arm) {
    # But cmake, which we use for building cpython, reports it as armv7l
    vendor = vendor/armv7l
    lib_subdir = lib
}
message(Selected vendor dir $$vendor)

python_bin.path = $$libexecdir
python_bin.files = $$vendor/bin/python3 \
                   $$vendor/bin/python3.13

python_lib.path = $$libdir
python_lib.files = $$vendor/lib/python3.13 \
                   $$vendor/lib/lib*

pyotherside.path = $$libdir/
pyotherside.files = $$vendor/usr/$$lib_subdir/qt5

INSTALLS += python_bin python_lib pyotherside
