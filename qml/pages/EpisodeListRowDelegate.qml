/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../modules/Opal/Delegates" as D

D.TwoLineDelegate {
    id: root
    property bool switchVisible: true
    property string title: episode.episodeName
    property string subtitle: episode.airDate
    property var episode: undefined

    property bool _isWatched: episode.isWatched || false
    property bool _isAired: episode.hasAired || false

    signal watchToggled(bool watched)

    text: title
    description: subtitle

    leftItem: Switch {
        height: minContentHeight
        width: minContentHeight
        visible: switchVisible
        checked: episode.isWatched
        onClicked: root.watchToggled(checked)
    }

    padding.topBottom: Theme.paddingSmall
    minContentHeight: Theme.itemSizeSmall - padding.effectiveTop - padding.effectiveBottom
    descriptionLabel.font.pixelSize: Theme.fontSizeTiny

    textLabel.palette {
        primaryColor: root.palette.primaryColor
        highlightColor: root.palette.highlightColor
    }
    descriptionLabel.palette {
        primaryColor: root.palette.secondaryColor
        highlightColor: root.palette.secondaryHighlightColor
    }

    palette {
        primaryColor: (_isWatched || !_isAired) ?
                          Theme.secondaryColor : Theme.primaryColor
        secondaryColor: (_isWatched || !_isAired) ?
                            Theme.rgba(Theme.secondaryColor, Theme.opacityHigh) :
                            Theme.secondaryColor
        highlightColor: (_isWatched || !_isAired) ?
                            Theme.secondaryHighlightColor : Theme.highlightColor
        secondaryHighlightColor: (_isWatched || !_isAired) ?
                                     Theme.rgba(Theme.secondaryHighlightColor, Theme.opacityHigh) :
                                     Theme.secondaryHighlightColor
    }
}
