/*
 * This file is part of SeriesFinale.
 * SPDX-FileCopyrightText: 2025 Smooth-E
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <QtQuick>
#include <auroraapp.h>

int main(int argc, char *argv[])
{
    if (qputenv("PYTHONHOME", QString("/usr/share/moe.smoothie.seriesfinale/").toUtf8().constData())) {
        qDebug() << "Successfully set python home";
    } else {
        qDebug() << "Failed to set python home";
    }

    QScopedPointer<QGuiApplication> app(Aurora::Application::application(argc, argv));
    app->setOrganizationName("moe.smoothie");
    app->setApplicationName("seriesfinale");

    QScopedPointer<QQuickView> view(Aurora::Application::createView());

    // Vendored pyotherside
    view->engine()->addImportPath(Aurora::Application::pathTo("lib/qt5/qml").toString());

    view->setSource(Aurora::Application::pathToMainQml());
    view->show();

    return app->exec();
}
