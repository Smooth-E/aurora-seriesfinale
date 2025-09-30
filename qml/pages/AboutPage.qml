/*
 * This file is part of harbour-seriesfinale.
 * SPDX-FileCopyrightText: 2024-2025 Mirian Margiani
 * SPDX-FileCopyrightText: 2025 Smooth-E
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../modules/Opal/About" 1.0

AboutPageBase {
    id: root
    allowedOrientations: Orientation.All

    appName: "SeriesFinale"
    appIcon: Qt.resolvedUrl("../images/harbour-seriesfinale.png")
    appVersion: python.version
    appRelease: "1"
      description: qsTr("A TV series database app that helps you " +
                        "keep track of what you are watching.")
    sourcesUrl: "https://github.com/Smooth-E/aurora-seriesfinale"

    authors: [
        "2015-%1 Core Comic and contributors".arg((new Date()).getFullYear()),
    ]
    licenses: License { spdxId: "GPL-3.0-or-later" }

    PullDownMenu {
        parent: root.flickable

        MenuItem {
            text: qsTr("Statistics")
            onClicked: pageStack.push(Qt.resolvedUrl("StatisticsPage.qml"))
        }
    }

    property string tvdbLink: "https://www.thetvdb.com"
    extraSections: InfoSection {
        title: qsTr("Data")
        text: qsTr("SeriesFinale uses <a href='%1'>TheTVDB</a> API but is not endorsed or certified by TheTVDB. " +
                   "Please contribute to it if you can.", "Note: “TheTVDB” is a trademark, so don't translate that.")
                   .arg(tvdbLink)
    }

    /*changelogItems: [
        // add new items at the top of the list
        ChangelogItem {
            version: "1.0.0-1"
            date: "2023-01-02"  // optional
            author: "Au Thor"   // optional
            paragraphs: "A short paragraph describing this initial version."
        }
    ]*/

    /*donations.text: donations.defaultTextCoffee
    donations.services: DonationService {
        name: "LiberaPay"
        url: "liberapay.com"
    }*/

    attributions: [
        Attribution {
            name: "SeriesFinale (Python)"
            entries: ["2009 Joaquim Rocha"]
            licenses: License { spdxId: "GPL-3.0-or-later" }
        },
        Attribution {
            name: "PyOtherSide"
            entries: ["2011, 2013-2020 Thomas Perl"]
            licenses: License { spdxId: "ISC" }
            sources: "https://github.com/thp/pyotherside"
            homepage: "https://thp.io/2011/pyotherside/"
        }
    ]

    contributionSections: [
        ContributionSection {
            groups: [
                ContributionGroup {
                    title: qsTr("Programming")
                    entries: [
                        "Core Comic",
                        "Joaquim Rocha",
                        "Juan Suarez Romero",
                        "Micke Prag",
                        "Mirian Margiani",
                        "Smooth-E"
                    ]
                },
                ContributionGroup {
                    title: qsTr("Icon Design")
                    entries: ["Core Comic"]
                },
                ContributionGroup {
                    title: qsTr("Aurora OS port")
                    entries: [ "Smooth-E" ]
                }
            ]
        },
        ContributionSection {
            title: qsTr("Translations")
            groups: [
                ContributionGroup {
                    title: qsTr("English")
                    entries: ["Core Comic"]
                },
                ContributionGroup {
                    title: qsTr("Spanish")
                    entries: ["Carmen F. B."]
                },
                ContributionGroup {
                    title: qsTr("Swedish")
                    entries: ["Åke Engelbrektson"]
                },
                ContributionGroup {
                    title: qsTr("German")
                    entries: ["Core Comic", "Mirian Margiani"]
                },
                ContributionGroup {
                    title: qsTr("Russian")
                    entries: [ "Smooth-E" ]
                }
            ]
        }
    ]
}
