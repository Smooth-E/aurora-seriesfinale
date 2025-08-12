/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: coverPage

    Item {
        anchors.fill: parent
        opacity: 0.9

        Image {
            id: backgroundImage
            source: app.coverImage
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height
            sourceSize {
                width: parent.width
                height: parent.height
            }
            fillMode: Image.PreserveAspectCrop
            clip: true
        }

        OpacityRampEffect {
            sourceItem: backgroundImage
            direction: OpacityRamp.TopToBottom
            slope: 2.0
            offset: 0.3
        }
    }

    Label {
        id: label
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingMedium
            horizontalCenter: parent.horizontalCenter
        }

        text: 'SeriesFinale'
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.highlightColor
    }
}


