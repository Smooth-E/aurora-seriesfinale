/*
 * This file is part of harbour-seriesfinale.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 Mirian Margiani
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0

GridLayout {
    id: root

    width: parent.width
    columns: 2
    columnSpacing: Theme.paddingMedium
    rowSpacing: Theme.paddingMedium

    // note: GridLayout items are added upside down,
    // from bottom to top.
}
