/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0

import "../modules/Opal/LinkHandler" 1.0 as L
import '../util.js' as Util
import "components"

Dialog {
    id: root

    property var show

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: column.width
        contentHeight: column.height + Theme.horizontalPageMargin

        VerticalScrollDecorator { flickable: flickable }

        Column {
            id: column

            width: root.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: show.showName
            }

            InfoBox {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x

                Row {
                    width: parent.width
                    height: childrenRect.height
                    spacing: Theme.paddingLarge

                    Image {
                        id: cover
                        source: show.coverImage
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
                            label: qsTr("Links")
                            value: '<a href="#">IMDB</a>'

                            valueLabel {
                                linkColor: Theme.primaryColor
                                onLinkActivated: {
                                    var imdbUrl = 'http://www.imdb.com/title/' + show.imdbId
                                    L.LinkHandler.openOrCopyUrl(imdbUrl)
                                }
                            }
                        }
                        InfoGridItem {
                            grid: parent
                            label: qsTr("Runtime")
                            value: qsTr("%1 min", "as in “this episode is 30 minutes long").arg(show.runtime)
                        }
                        InfoGridItem {
                            grid: parent
                            label: qsTr("Genre")
                            value: show.showGenre
                        }
                    }
                }
            }

            SectionHeader {
                text: qsTr("Description")
                visible: !!show.showOverview
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2*Theme.horizontalPageMargin
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryHighlightColor
                wrapMode: Text.Wrap
                text: show.showOverview

                linkColor: Theme.primaryColor
                onLinkActivated: L.LinkHandler.openOrCopyUrl(link)
            }
        }
    }
}
