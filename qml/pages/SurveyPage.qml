/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 * SPDX-FileCopyrightText: 2015-2017 Core Comic
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../modules/Opal/SmartScrollbar" as S
import '../util.js' as Util

Page {
    id: surveyPage

    property bool isLoading: false
    property bool isUpdating: false
    property bool doHighlight: false
    property bool hasChanged: false

    function update() {
        python.call('seriesfinale.seriesfinale.series_manager.get_series_list_by_prio', [], function(result) {
            // Load the received data into the list model
            Util.updateModelFrom(seriesListByPrio, result);
            isLoading = false;
            hasChanged = false;
        });
    }

    onStatusChanged: {
        if (status === PageStatus.Activating && hasChanged) {
            isLoading = true;
            update();
        }
    }

    Connections {
        target: python

        onSettingsChanged: {
            update()
        }

        onLoadingChanged: {
            surveyPage.isLoading = true;
            if(!loading) {
                update();
            }
        }

        onShowListChanged: {
            if (changed) {
                update()
            }
        }

        onCoverImageChanged: {
            for (var i=0; i<seriesListByPrio.count; i++) {
                var show = seriesListByPrio.get(i);
                if (show.showName === name) {
                    seriesListByPrio.setProperty(i, 'coverImage', image);
                    break;
                }
            }
        }

    }


    SilicaListView {
        id: listView
        anchors.fill: parent

        // PullDownMenu
        PullDownMenu {
            busy: isUpdating

            MenuItem {
                text: qsTr("Add Show")
                visible: !isUpdating
                onClicked: { pageStack.push(Qt.resolvedUrl("AddShow.qml")) }
            }

            MenuLabel {
                visible: isUpdating
                text: qsTr("Refreshing...")
            }
        }

        header: PageHeader {
            id: header
            title: qsTr("Survey Page")
        }

        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }

        model: ListModel {
            id: seriesListByPrio
        }

        section.property: "priority"
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader {
            text: prioListModel[section].name
        }

        delegate: ListRowDelegate {
            id: item

            text: model.showName
            description: model.infoMarkup
            isUpdating: model.isUpdating
            isPremiere: model.nextIsPremiere && doHighlight
            isShowPremiere: model.isShowPremiere && doHighlight
            priority: model.priority
            iconSource: model.coverImage
            infoLines: 3

            menu: Component {
                ContextMenu {
                    MenuItem {
                        text: qsTr('Change show priority')
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("PrioritySelectionDialog.qml"),
                                           {showName: model.showName})
                        }
                    }

                    MenuItem {
                        text: qsTr("Delete show")
                        onClicked: {
                            item.remorseDelete((function(){
                                this.python.call('seriesfinale.seriesfinale.series_manager.delete_show_by_name',
                                                 [this.model.showName])
                                this.item.animateRemoval(this.item)
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
            enabled: surveyPage.status == PageStatus.Active &&
                     !surveyPage.isLoading &&
                     seriesListByPrio.count == 0
        }

        BusyIndicator {
            id: loadingIndicator
            visible: surveyPage.isLoading || !python.ready
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

            text: !!listView.currentSection ? prioListModel[listView.currentSection].name : " "
            description: "%1 / %2".arg(scrollIndex+2).arg(flickable.count)
        }
    }

    Component.onCompleted: {
        update()
    }
}
