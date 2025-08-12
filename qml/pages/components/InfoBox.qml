/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0

Rectangle {
    id: root

    default property alias contents: container.data
    property int padding: Theme.paddingLarge

    width: parent.width
    height: childrenRect.height + 2*padding

    color: Theme.rgba(Theme.highlightDimmerColor, Theme.opacityFaint)
    radius: 50
    border {
        color: Theme.highlightColor
        width: 1
    }

    Item {
        id: container

        anchors {
            top: parent.top
            topMargin: parent.padding
        }
        x: parent.padding
        width: parent.width - 2*x
        height: childrenRect.height
    }
}
