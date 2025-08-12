import QtQuick 2.0
import Sailfish.Silica 1.0

import '../util.js' as Util

Page {
    id: seriesPage

    property bool isUpdating: false
    property bool isLoading: false
    property bool hasChanged: false
    property bool doHighlight: false

    function getRandomNumber(min, max) {
        return Math.random() * (max - min) + min;
    }

    function update() {
        python.call('seriesfinale.seriesfinale.series_manager.get_series_list', [], function(result) {
            // Load the received data into the list model
            Util.updateModelFrom(seriesList, result);

            isLoading = false;
            hasChanged = false;
            coverImage = seriesList.get(getRandomNumber(0, result.length)).coverImage;
        });

        python.call('seriesfinale.seriesfinale.settingsWrapper.getSortByGenre', [], function(result) {
            if (result) {
                listView.section.property = "showGenre"
            } else {
                listView.section.property = ""
            }
        })

        python.call('seriesfinale.seriesfinale.settingsWrapper.getHighlightSpecial', [], function(result) {
            doHighlight = result;
        })
    }

    onStatusChanged: {
        if (status === PageStatus.Activating && hasChanged) {
            update();
        }

        if (status === PageStatus.Active && !canNavigateForward) {
            pageStack.pushAttached(Qt.resolvedUrl("SurveyPage.qml"), {
                                       isUpdating: Qt.binding(function(){return isUpdating}),
                                       hasChanged: Qt.binding(function(){return hasChanged}),
                                       doHighlight: Qt.binding(function(){return doHighlight}),
                                   });
        }
    }

    Connections {
        target: python

        onLoadingChanged: {
            seriesPage.isLoading = true;
            if(!loading) {
                update();
            }
        }

        onUpdatingChanged: {
            seriesPage.isUpdating = updating;
        }

        onShowListChanged: {
            if (changed) {
                update()
            }
        }

        onCoverImageChanged: {
            for (var i=0; i<seriesList.count; i++) {
                var show = seriesList.get(i);
                if (show.showName === name) {
                    seriesList.setProperty(i, 'coverImage', image);
                    break;
                }
            }
        }

        onEpisodesListUpdating: {
            for (var i=0; i<seriesList.count; i++) {
                var show = seriesList.get(i);
                if (show.showName === name) {
                    seriesList.setProperty(i, 'isUpdating', true);
                    break;
                }
            }
        }

        onEpisodesListUpdated: {
            for (var i=0; i<seriesList.count; i++) {
                if (seriesList.get(i).showName === show.showName) {
                    seriesList.set(i, show);
                    break;
                }
            }
        }

        onInfoMarkupChanged: hasChanged = true
    }

    SilicaListView {
        id: listView
        anchors.fill: parent
        spacing: Theme.paddingMedium

        // PullDownMenu
        PullDownMenu {
            busy: isUpdating

            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(aboutComponent.createObject(pageStack))
                Component { id: aboutComponent; AboutPage {} }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(settingsComponent.createObject(pageStack))
                Component { id: settingsComponent; SettingsPage {} }
            }
            MenuItem {
                text: qsTr("Refresh")
                visible: seriesList.count != 0 && !isUpdating
                onClicked: {
                    python.call('seriesfinale.seriesfinale.settingsWrapper.setLastCompleteUpdate', [new Date().toISOString().slice(0, 10)]);
                    python.call('seriesfinale.seriesfinale.series_manager.update_all_shows_episodes', []);
                }
            }
            MenuItem {
                text: qsTr("Add Show")
                visible: !seriesPage.isUpdating
                onClicked: { pageStack.push(addShowComponent.createObject(pageStack)) }
                Component { id: addShowComponent; AddShow {} }
            }

            MenuLabel {
                visible: isUpdating
                text: qsTr("Refreshing...")
            }
        }

        header: PageHeader {
            id: header
            title: "SeriesFinale"
        }

        model: ListModel {
            id: seriesList
        }

        section.property: ""
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader {
            text: section
        }

        delegate: ListRowDelegate {
            id: listDelegate

            isUpdating: model.isUpdating
            isPremiere: model.nextIsPremiere && doHighlight
            isShowPremiere: model.isShowPremiere && doHighlight
            title: model.showName
            subtitle: model.infoMarkup
            iconSource: model.coverImage
            priority: model.priority
            Component {
                id: showPageComponent
                ShowPage { show: model }
            }

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        id: markNextItem
                        visible: !model.isWatched
                        text: qsTr('Mark next episode')
                        onClicked: {
                            python.call('seriesfinale.seriesfinale.series_manager.mark_next_episode_watched', [true, model.showName])
                            seriesPage.update()
                        }
                    }
                    MenuItem {
                        id: markAllItem
                        visible: !model.isWatched
                        text: qsTr('Mark show as watched')
                        onClicked: {
                            python.call('seriesfinale.seriesfinale.series_manager.mark_all_episodes_watched', [true, model.showName])
                            seriesPage.update()
                        }
                    }
                    MenuItem {
                        text: qsTr("Delete show")
                        onClicked: showRemorseItem()
                    }
                }
            }

            RemorseItem { id: remorse }
            function showRemorseItem() {
                remorse.execute(listDelegate, qsTr("Deleting"), function() {
                    python.call('seriesfinale.seriesfinale.series_manager.delete_show_by_name', [model.showName]);
                    //seriesList.remove(index);
                })
            }

            onClicked: {
                pageStack.push(showPageComponent.createObject(pageStack));
            }
        }

        ViewPlaceholder {
            id: emptyText
            text: qsTr('No shows')
            enabled: seriesList.count == 0 && !seriesPage.isLoading
        }

        BusyIndicator {
            id: loadingIndicator
            visible: seriesPage.isLoading || !python.ready
            running: visible
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

        VerticalScrollDecorator {}
    }
}
