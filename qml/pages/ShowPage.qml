/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 * SPDX-FileCopyrightText: 2015-2016 Core Comic
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import '../util.js' as Util

Page {
    id: showPage
    property variant show: undefined

    property bool isUpdating: false
    property bool hasChanged: false

    function update() {
        python.call('seriesfinale.seriesfinale.series_manager.get_seasons_list', [show.showName], function(result) {
            // Load the received data into the list model
            Util.updateModelFrom(seasonList, result);
            hasChanged = false;
        });
    }

    Component.onCompleted: update()

    onShowChanged: {}
    onStatusChanged: {
        if (status === PageStatus.Activating && hasChanged) {
            update();
        }
    }

    Connections {
        target: python

        onShowUpdatingChanged: {
            showPage.isUpdating = updating;
            if(!updating) {
                update();
            }
        }

        onInfoMarkupChanged: hasChanged = true

        onShowArtChanged: {
            python.call('seriesfinale.seriesfinale.series_manager.get_seasons_list', [show.showName], function(result) {
                Util.updateModelWith(seasonList, 'seasonImage', '', result);
            });
        }

        //onInfoMarkupChanged: {
        //    delegate.subtitle = show.get_season_info_markup(model.data)
        //    markAllItem.text = show.is_completely_watched(model.data) ? 'Mark None' : 'Mark All'
        //}
    }

    SilicaListView {
        id: listView
        anchors.fill: parent

        // PullDownMenu
        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                visible: seasonList.count != 0 && !isUpdating
                onClicked: {
                    python.call('seriesfinale.seriesfinale.series_manager.update_show_by_name', [show.showName])
                }
            }
            MenuItem {
                text: qsTr("Info")
                onClicked: pageStack.push(Qt.resolvedUrl("ShowInfoDialog.qml"), {show: showPage.show})
            }
            MenuLabel {
                visible: isUpdating
                text: qsTr("Refreshing...")
            }
        }

        header: PageHeader {
            id: header
            title: show.showName
            wrapMode: Text.Wrap
            _titleItem.horizontalAlignment: Text.AlignRight
        }

        footer: Item {
            width: parent.width
            height: Theme.horizontalPageMargin
        }

        model: ListModel {
            id: seasonList
        } //show.get_seasons_model()

        delegate: ListRowDelegate {
            id: item

            text: model.seasonName
            description: model.seasonInfoMarkup
            iconSource: model.seasonImage
            infoLines: 2

            menu: Component {
                ContextMenu {
                    MenuItem {
                        id: markAllItem
                        text: model.isWatched ? qsTr('Mark None') : qsTr('Mark All')
                        onClicked: {
                            if (model.isWatched) {
                                python.call('seriesfinale.seriesfinale.series_manager.mark_all_episodes_watched',
                                            [false, showPage.show.showName, model.seasonNumber])
                            } else {
                                python.call('seriesfinale.seriesfinale.series_manager.mark_all_episodes_watched',
                                            [true, showPage.show.showName, model.seasonNumber])
                            }
                            showPage.update()
                        }
                    }
                    MenuItem {
                        text: qsTr("Delete season");
                        onClicked: {
                            item.remorseDelete((function(){
                                this.python.call('seriesfinale.seriesfinale.series_manager.delete_season',
                                                 [this.showPage.show.showName, this.model.seasonNumber])
                                this.item.animateRemoval(this.item)
                            }).bind({python: python, item: item, showPage: showPage, model: model}))
                        }
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("SeasonPage.qml"), {
                                   show: showPage.show,
                                   season: model,
                                   model: seasonList,
                                   index: index,
                               })
            }
        }

        ViewPlaceholder {
            id: emptyText
            text: qsTr('No seasons')
            enabled: showPage.status == PageStatus.Active &&
                     !showPage.isLoading &&
                     !showPage.isUpdating &&
                     seasonList.count == 0
        }

        BusyIndicator {
            id: loadingIndicator
            visible: showPage.isUpdating
            running: visible
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }
}
