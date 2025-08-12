/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 * SPDX-FileCopyrightText: 2015-2017 Core Comic
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../modules/Opal/Delegates" 1.0 as D

Page {
    id: root

    property bool isSearching: false
    property string searchLanguage: 'en'

    readonly property int _limit: 15

    Component.onCompleted: {
        searchField.forceActiveFocus()
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            python.call('seriesfinale.seriesfinale.settingsWrapper.getSearchLanguage', [], function(result) {
                searchLanguage = result;
            })
        }
    }

    function search() {
        parent.focus = true //Make sure the keyboard closes and the text is updated
        python.call('seriesfinale.seriesfinale.series_manager.search_shows',
                    [searchField.text, searchLanguage], function() {});
    }

    Connections {
        target: python

        onSearchingChanged: {
            root.isSearching = searching;
            if(!searching) {
                python.call('seriesfinale.seriesfinale.series_manager.search_result_model', [], function(result) {
                    // Clear the data in the list model
                    listModel.clear();

                    // Load the received data into the list model
                    for (var i=0; i<result.length; i++) {
                        listModel.append(result[i]);

                        if (i > _limit) {
                            break
                        }
                    }
                });
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.horizontalPageMargin

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                text: qsTr('Search options')
                onClicked: pageStack.push(Qt.resolvedUrl("SearchSettingsPage.qml"), {language: searchLanguage})
            }
        }

        Column {
            id: column
            width: root.width

            PageHeader {
                title: qsTr("Add show")

                BusyIndicator {
                    size: BusyIndicatorSize.Large
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.bottom
                        topMargin: searchField.height + Theme.itemSizeLarge
                    }
                    visible: isSearching
                    running: visible
                }
            }

            SearchField {
                id: searchField

                width: parent.width
                placeholderText: qsTr("Search")
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText

                onTextChanged: {
                    //search();
                }

                EnterKey.onClicked: {
                    if (text != "")
                        searchField.focus = false;
                    search();
                }
            }

            Repeater {
                width: parent.width

                model: ListModel {
                    id: listModel
                }

                delegate: D.TwoLineDelegate {
                    id: item
                    text: model.series_name
                    description: model.start_year

                    padding {
                        right: 0
                        topBottom: 0
                    }

                    textLabel.font.bold: true
                    descriptionLabel.font.bold: true

                    onClicked: {
                        python.call('seriesfinale.seriesfinale.series_manager.get_complete_show',
                                    [model.series_name, searchLanguage], function() {});
                        pageStack.pop()
                    }

                    menu: Component {
                        ContextMenu {
                            MenuLabel {
                                text: model.series_name
                            }

                            MenuLabel {
                                text: model.blurb || qsTr("No description available.")
                                truncationMode: TruncationMode.Elide
                            }
                        }
                    }

                    Item {
                        z: -1
                        opacity: Theme.opacityLow
                        anchors {
                            left: parent.left
                            leftMargin: -item.padding.effectiveLeft
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }

                        Image {
                            id: banner
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: model.banner_url
                            sourceSize {
                                width: width
                                height: height
                            }
                        }

                        OpacityRampEffect {
                            sourceItem: banner
                            direction: OpacityRamp.RightToLeft
                            slope: 2.0
                            offset: 0.3
                        }
                    }
                }
            }
        }
    }
}
