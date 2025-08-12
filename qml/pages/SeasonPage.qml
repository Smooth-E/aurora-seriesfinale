/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 * SPDX-FileCopyrightText: 2015-2016 Core Comic
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import '../util.js' as Util

Dialog {
    id: seasonPage
    property variant season: undefined
    property variant show: undefined

    property bool isUpdating: false
    property bool isWatched: season.isWatched

    property ListModel model: null
    property int index: -1

    readonly property var _nextSeason: model.get(index + 1) || null

    function update() {
        python.call('seriesfinale.seriesfinale.series_manager.get_episodes_list', [show.showName, season.seasonNumber], function(result) {
            // Load the received data into the list model
            Util.updateModelFrom(episodesList, result);
        });
    }

    acceptDestination: !!_nextSeason ? Qt.resolvedUrl("SeasonPage.qml") : null
    acceptDestinationProperties: ({
        show: show,
        season: _nextSeason,
        model: model,
        index: index + 1,
    })
    acceptDestinationAction: PageStackAction.Replace

    Component.onCompleted: update()

    onSeasonChanged:{}
    onShowChanged: {}

    Connections {
        target: python

        onInfoMarkupChanged: {
            update();
        }

    }

    SilicaListView {
        id: listView
        anchors.fill: parent

        // PullDownMenu
        PullDownMenu {
            MenuItem {
                id: menuMarkAll
                visible: !isWatched
                text: qsTr("Mark all")
                onClicked: {
                    python.call('seriesfinale.seriesfinale.series_manager.mark_all_episodes_watched', [true, seasonPage.show.showName, season.seasonNumber]);
                    isWatched = true;
                }
            }
            MenuItem {
                id: menuMarkNone
                visible: isWatched
                text: qsTr("Mark none")
                onClicked: {
                    python.call('seriesfinale.seriesfinale.series_manager.mark_all_episodes_watched', [false, seasonPage.show.showName, season.seasonNumber]);
                    isWatched = false;
                }
            }
        }

        header: PageHeader {
            id: header
            title: season.seasonName
            description: show.showName
            wrapMode: Text.Wrap
            descriptionWrapMode: Text.Wrap
            _titleItem.horizontalAlignment: Text.AlignRight
        }

        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }

        model: ListModel {
            id: episodesList
        } // show.get_sorted_episode_list_by_season(season)

        delegate: EpisodeListRowDelegate {
            episode: model
            onClicked: {
                pageStack.push(Qt.resolvedUrl("EpisodePage.qml"), {
                                   show: seasonPage.show,
                                   episode: model,
                                   model: episodesList,
                                   index: index,
                                   seasonCover: season.seasonImage,
                               })
            }
            onWatchToggled: {
                python.call('seriesfinale.seriesfinale.series_manager.set_episode_watched',
                            [watched, seasonPage.show.showName, model.episodeName]);
            }
        }

        ViewPlaceholder {
            id: emptyText
            text: qsTr('No episodes')
            enabled: episodesList.count == 0 && !seasonPage.isUpdating
        }

        BusyIndicator {
            id: loadingIndicator
            visible: seasonPage.isUpdating
            running: visible
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }
}
