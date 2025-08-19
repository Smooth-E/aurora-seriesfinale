/*
 * This file is part of harbour-seriesfinale.
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 * SPDX-FileCopyrightText: 2025 Smooth-E
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../modules/Opal/Delegates" as D

D.TwoLineDelegate {
    id: root

    text: ""
    description: ""
    property string iconSource
    property bool isUpdating: false
    property bool isPremiere: false
    property bool isShowPremiere: false
    property int priority: -1
    property int infoLines: 3

    minContentHeight: 2*Theme.paddingMedium +
                      Theme.fontSizeMedium +
                      Theme.paddingSmall +
                      infoLines*Theme.fontSizeTiny

    textLabel.font {
        bold: isPremiere
        underline: isShowPremiere
    }

    descriptionLabel {
        // _elideText: false
        font.pixelSize: Theme.fontSizeTiny
    }

    leftItem: Item {
        height: minContentHeight
        width: Math.max(height / 1.445, childrenRect.width)

        Image {
            anchors {
                left: parent.left
                leftMargin: Theme.paddingSmall
            }
            height: parent.height
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: false
            source: root.iconSource
            opacity: root.isUpdating ?
                         0.2 : String(source).indexOf('placeholderimage') > -1 ? 0.5 : 1.0

        }

        BusyIndicator {
            anchors.centerIn: parent
            visible: root.isUpdating
            running: visible
        }

        Rectangle {
            anchors.left: parent.left
            visible: priority >= 0
            color: app.prioListModel.hasOwnProperty(root.priority) ?
                       app.prioListModel[priority].color : "grey"
            height: parent.height
            width: Theme.paddingSmall / 2
        }
    }
}
