/*

BTtons (harbour-btbuttons)
Copyright (C) 2019  John Gibbon

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/
#ifdef QT_QML_DEBUG
#endif
#include <QtQuick>

#include <sailfishapp.h>
#include "launcher.h"
#include <QDebug>

int main(int argc, char *argv[])
{

    QCoreApplication::setSetuidAllowed(true);


    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
//    QScopedPointer<QQuickView> view(SailfishApp::createView());

//    QCoreApplication cliapp(argc, argv);
    QCoreApplication::setApplicationName("slumber-privileged");
    QCoreApplication::setApplicationVersion("1.0");

    QCommandLineParser parser;
    QTextStream out(stdout);
    parser.addOption({{"b", "background"}, "Start auto-managed background process."});
    parser.addOption({{"v", "verbose"}, "Display all kinds of things."});
//    QCommandLineOption bgOption("background", "Start auto-managed background process");
//    parser.addOption(bgOption);
    parser.setApplicationDescription("BTtons");
    parser.addHelpOption();
    // Process the actual command line arguments given by the user
    parser.process(QCoreApplication::arguments());
    qDebug() << "bg option" << parser.value("background") <<  parser.isSet("background");
//    parser.addVersionOption();

    qmlRegisterType<Launcher>("Launcher", 1 , 0 , "Launcher");

    if(parser.isSet("background")) {
        QQmlEngine engine;
        QObject::connect(&engine, &QQmlApplicationEngine::quit, &QGuiApplication::quit);
        QQmlComponent component(&engine, SailfishApp::pathTo("qml/bg.qml"));
        engine.rootContext()->setContextProperty("verbose", parser.isSet("verbose"));
//        component.setProperty("verbose", parser.isSet("verbose"));
        component.create();
        return app->exec();
    }
    else { // normal gui app

        QScopedPointer<QQuickView> view(SailfishApp::createView());
    //    QQmlEngine *engine = view->engine();
        view->rootContext()->setContextProperty("executablePath", QCoreApplication::applicationFilePath());
        view->rootContext()->setContextProperty("verbose", parser.isSet("verbose"));
        view->setSource(SailfishApp::pathToMainQml());
        view->showFullScreen();
        return app->exec();



    }
}
