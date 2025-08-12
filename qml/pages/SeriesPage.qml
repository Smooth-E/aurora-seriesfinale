/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 * SPDX-FileCopyrightText: 2015-2016 Core Comic
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../modules/Opal/SmartScrollbar" as S
import '../util.js' as Util

Page {
    id: seriesPage

    Component.onCompleted: {
        update()
    }

    property bool isUpdating: false
    property bool isLoading: false
    property bool hasChanged: false
    property bool doHighlight: false

    function getRandomNumber(min, max) {
        return Math.random() * (max - min) + min;
    }

    function update() {
        python.call('seriesfinale.seriesfinale.series_manager.get_series_list', [], function(result) {
            // Load the received data into the list model
            Util.updateModelFrom(seriesList, result);

            isLoading = false;
            hasChanged = false;

            var random = seriesList.get(getRandomNumber(0, result.length))

            if (!!random) {
                coverImage = random.coverImage
            }
        });

        python.call('seriesfinale.seriesfinale.settingsWrapper.getSortByGenre', [], function(result) {
            if (result) {
                listView.section.property = "showGenre"
            } else {
                listView.section.property = ""
            }
        })

        python.call('seriesfinale.seriesfinale.settingsWrapper.getHighlightSpecial', [], function(result) {
            doHighlight = result;
        })
    }

    onStatusChanged: {
        if (status === PageStatus.Activating && hasChanged) {
            update();
        }

        if (status === PageStatus.Active && !canNavigateForward) {
            pageStack.pushAttached(Qt.resolvedUrl("SurveyPage.qml"), {
                                       isUpdating: Qt.binding(function(){return isUpdating}),
                                       hasChanged: Qt.binding(function(){return hasChanged}),
                                       doHighlight: Qt.binding(function(){return doHighlight}),
                                   });
        }
    }

    Connections {
        target: python

        onSettingsChanged: {
            hasChanged = true
            update()
        }

        onLoadingChanged: {
            seriesPage.isLoading = true;
            if(!loading) {
                update();
            }
        }

        onUpdatingChanged: {
            seriesPage.isUpdating = updating;
        }

        onShowListChanged: {
            if (changed) {
                update()
            }
        }

        onCoverImageChanged: {
            for (var i=0; i<seriesList.count; i++) {
                var show = seriesList.get(i);
                if (show.showName === name) {
                    seriesList.setProperty(i, 'coverImage', image);
                    break;
                }
            }
        }

        onEpisodesListUpdating: {
            for (var i=0; i<seriesList.count; i++) {
                var show = seriesList.get(i);
                if (show.showName === name) {
                    seriesList.setProperty(i, 'isUpdating', true);
                    break;
                }
            }
        }

        onEpisodesListUpdated: {
            for (var i=0; i<seriesList.count; i++) {
                if (seriesList.get(i).showName === show.showName) {
                    seriesList.set(i, show);
                    break;
                }
            }
        }

        onInfoMarkupChanged: hasChanged = true
    }

    SilicaListView {
        id: listView
        anchors.fill: parent

        // PullDownMenu
        PullDownMenu {
            busy: isUpdating

            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Refresh")
                visible: seriesList.count != 0 && !isUpdating
                onClicked: {
                    python.call('seriesfinale.seriesfinale.settingsWrapper.setLastCompleteUpdate', [new Date().toISOString().slice(0, 10)]);
                    python.call('seriesfinale.seriesfinale.series_manager.update_all_shows_episodes', []);
                }
            }
            MenuItem {
                text: qsTr("Add Show")
                visible: !seriesPage.isUpdating
                onClicked: { pageStack.push(Qt.resolvedUrl("AddShow.qml")) }
            }

            MenuLabel {
                visible: isUpdating
                text: qsTr("Refreshing...")
            }
        }

        header: PageHeader {
            id: header
            title: "SeriesFinale"
        }

        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }

        model: ListModel {
            id: seriesList
        }

        section.property: ""
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader {
            text: section
        }

        delegate: ListRowDelegate {
            id: item
            text: model.showName
            description: model.infoMarkup
            iconSource: model.coverImage
            isUpdating: model.isUpdating
            isPremiere: model.nextIsPremiere && doHighlight
            isShowPremiere: model.isShowPremiere && doHighlight
            priority: model.priority
            infoLines: 3

            menu: Component {
                ContextMenu {
                    MenuItem {
                        visible: !model.isWatched
                        text: qsTr('Mark next episode')
                        onClicked: {
                            python.call('seriesfinale.seriesfinale.series_manager.mark_next_episode_watched', [true, model.showName],
                                        function(){seriesPage.update()})
                        }
                    }
                    MenuItem {
                        visible: !model.isWatched
                        text: qsTr('Mark show as watched')
                        onClicked: {
                            python.call('seriesfinale.seriesfinale.series_manager.mark_all_episodes_watched', [true, model.showName],
                                        function(){seriesPage.update()})
                        }
                    }
                    MenuItem {
                        text: qsTr("Delete show")
                        onClicked: {
                            item.remorseDelete((function(){
                                this.python.call('seriesfinale.seriesfinale.series_manager.delete_show_by_name',
                                                 [this.model.showName])
                            }).bind({python: python, item: item, model: model}))
                        }
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("ShowPage.qml"), {show: model});
            }
        }

        ViewPlaceholder {
            id: emptyText
            text: qsTr('No shows')
            enabled: seriesList.count == 0 && !seriesPage.isLoading
        }

        BusyIndicator {
            id: loadingIndicator
            visible: seriesPage.isLoading || !python.ready
            running: visible
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        S.SmartScrollbar {
            flickable: listView
            readonly property int scrollIndex: {
                var idx = flickable.indexAt(flickable.contentX, flickable.contentY)
                if (idx < 0) idx = flickable.indexAt(flickable.contentX, flickable.contentY +
                                                     Theme.itemSizeMedium)
                return idx
            }

            text: listView.currentSection
            description: "%1 / %2".arg(scrollIndex+2).arg(flickable.count)
        }
    }
}
