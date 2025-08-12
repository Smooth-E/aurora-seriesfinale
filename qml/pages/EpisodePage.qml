/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../modules/Opal/MenuSwitch" 1.0 as M
import "../modules/Opal/LinkHandler" 1.0 as L
import "components"

Dialog {
    id: root

    property var show: ({showName: ""})
    property var episode: ({episodeName: ""})
    property string seasonCover

    property ListModel model: null
    property int index: -1

    readonly property var _nextEpisode: model.get(index + 1) || null

    function ratingToStars(rating) {
        var y = '★'
        var n = '☆'
        var ret = ''

        for (var i = 1; i <= 5; ++i) {
            if (rating >= i) {
                ret += y
            } else {
                ret += n
            }
        }

        return ret
    }

    acceptDestination: !!_nextEpisode ? Qt.resolvedUrl("EpisodePage.qml") : null
    acceptDestinationProperties: ({
        show: show,
        episode: _nextEpisode,
        model: model,
        index: index + 1,
        seasonCover: seasonCover,
    })
    acceptDestinationAction: PageStackAction.Replace

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        PullDownMenu {
            M.MenuSwitch {
                text: qsTr("Watched")
                checked: episode.isWatched
                automaticCheck: false
                onClicked: {
                    python.call('seriesfinale.seriesfinale.series_manager.set_episode_watched',
                                [!checked, show.showName, episode.episodeName])
                }
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: episode.episodeName
                description: show.showName
                wrapMode: Text.Wrap
                descriptionWrapMode: Text.Wrap
                _titleItem.horizontalAlignment: Text.AlignRight
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            InfoBox {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x

                /*
                // vvv Details page with season cover vvv
                // Disabled because it takes a lot of vertical screen space
                // and looks quite cramped.

                Row {
                    width: parent.width
                    height: childrenRect.height
                    spacing: Theme.paddingLarge

                    Image {
                        id: cover
                        source: seasonCover
                        height: 1.5*Theme.itemSizeExtraLarge
                        sourceSize.height: height
                        fillMode: Image.PreserveAspectFit
                        smooth: true

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Qt.openUrlExternally(show.coverImage)
                        }
                    }

                    InfoGrid {
                        width: parent.width - parent.spacing - cover.paintedWidth
                        anchors.verticalCenter: cover.verticalCenter

                        InfoGridItem {
                            grid: parent
                            label: qsTr("Runtime")
                            value: qsTr("%1 min", "as in “this episode is 30 minutes long").arg(show.runtime)
                        }
                        InfoGridItem {
                            grid: parent
                            label: qsTr("Air date")
                            value: episode.airDate
                        }
                        InfoGridItem {
                            grid: parent
                            label: qsTr("Rating")
                            value: ratingToStars(Math.ceil(episode.episodeRating/2))
                        }
                    }
                }
                */

                InfoGrid {
                    id: grid
                    columns: widthMetrics.width > width ? 2 : 4

                    TextMetrics {
                        id: widthMetrics
                        text: [dateInfo.label, dateInfo.value,
                               rateInfo.label, rateInfo.value].join(" ")
                        font: dateInfo.valueLabel.font
                    }

                    InfoGridItem {
                        id: dateInfo
                        grid: parent
                        label: qsTr("Air date")
                        value: episode.airDate
                        visible: !!episode.airDate
                    }
                    InfoGridItem {
                        id: rateInfo
                        grid: parent
                        label: qsTr("Rating")
                        value: ratingToStars(Math.ceil(episode.episodeRating/2))
                    }
                }
            }

            SectionHeader {
                text: qsTr("Description")
                visible: !!episode.overviewText
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2*Theme.horizontalPageMargin
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                text: episode.overviewText

                linkColor: Theme.primaryColor
                onLinkActivated: L.LinkHandler.openOrCopyUrl(link)
            }
        }
    }
}
