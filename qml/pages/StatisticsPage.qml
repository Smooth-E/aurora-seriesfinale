/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 * SPDX-FileCopyrightText: 2015-2016 Core Comic
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: statisticsPage

    property string numShows
    property string watchedShows
    property string endedShows
    property string numEpisodes
    property string watchedEpisodes
    property string timeWatched
    property string lastUpdate

    Component.onCompleted: {
        python.call('seriesfinale.seriesfinale.getStatistics', [], function(result) {
            numShows = result.numSeries;
            watchedShows = result.numSeriesWatched + ' (' + Math.round(100*result.numSeriesWatched/result.numSeries) + '%)';
            endedShows = result.numSeriesEnded;
            numEpisodes = result.numEpisodes;
            watchedEpisodes = result.numEpisodesWatched + ' (' + Math.round(100*result.numEpisodesWatched/result.numEpisodes) + '%)';
            timeWatched = Math.round(result.timeWatched/14.4)/100;
        })
        python.call('seriesfinale.seriesfinale.settingsWrapper.getLastCompleteUpdate', [], function(result) {
            lastUpdate = result;
        })
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column
            x: Theme.horizontalPageMargin
            width: parent.width - 2*x
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Statistics")
            }

            DetailItem {
                label: qsTr("Number of shows:")
                value: numShows
            }
            DetailItem {
                label: qsTr("Ended shows:")
                value: endedShows
            }
            DetailItem {
                label: qsTr("Watched shows:")
                value: watchedShows
            }
            DetailItem {
                label: qsTr("Number of episodes:")
                value: numEpisodes
            }
            DetailItem {
                label: qsTr("Watched episodes:")
                value: watchedEpisodes
            }
            DetailItem {
                label: qsTr("Days spent watching:")
                value: timeWatched
            }
            DetailItem {
                label: qsTr("Last refresh:")
                value: lastUpdate
            }
        }
    }
}
