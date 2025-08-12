/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024-2025 Mirian Margiani
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1

Item {
    id: root

    property GridLayout grid
    property string label
    property string value
    property bool busy: false

    property alias valueLabel: valueLabel
    property alias labelLabel: labelLabel

    // note: GridLayout items are added upside down,
    // from bottom to top.

    Label {
        id: valueLabel
        parent: grid
        visible: root.visible
        enabled: root.enabled
        leftPadding: root.busy ? spinner.width + Theme.paddingMedium : 0
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        text: value
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeMedium
        wrapMode: Text.Wrap

        BusyIndicator {
            id: spinner
            anchors {
                left: parent.left
                bottom: parent.baseline
            }
            visible: root.busy
            size: BusyIndicatorSize.ExtraSmall
            running: visible
        }
    }

    Label {
        id: labelLabel
        parent: grid
        visible: root.visible
        enabled: root.enabled
        Layout.fillWidth: false
        Layout.alignment: Qt.AlignRight
        anchors.baseline: valueLabel.baseline
        text: label
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignRight
    }
}
