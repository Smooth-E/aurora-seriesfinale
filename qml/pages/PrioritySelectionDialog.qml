/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../modules/Opal/Delegates" 1.0 as D

Dialog {
    id: root

    property string showName: ''
    property int selectedIndex: -1

    canAccept: false

    SilicaListView {
        id: view
        anchors.fill: parent
        model: prioListModel

        header: DialogHeader {
            title: qsTr("Select a priority")
        }

        VerticalScrollDecorator { flickable: view }

        delegate: D.OneLineDelegate {
            minContentHeight: Theme.itemSizeSmall
            text: modelData.name
            spacing: Theme.paddingLarge

            leftItem: Rectangle {
                color: modelData.color
                height: Theme.itemSizeExtraSmall
                radius: Math.round(width / 3)
                width: Theme.paddingSmall
            }

            onClicked: {
                root.selectedIndex = index;
                root.canAccept = true;
                root.accept();

                python.call('seriesfinale.seriesfinale.series_manager.set_show_priority',
                            [root.selectedIndex, root.showName],
                            function() { python.settingsChanged() })
            }
        }
    }
}
