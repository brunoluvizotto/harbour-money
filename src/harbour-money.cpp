/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <QtQuick>
#include <sailfishapp.h>
#include "options.h"
#include <QDate>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();

    Options options;
    view->rootContext()->setContextProperty("options", &options);

    QString loadLanguage;
    if (options.getLanguage() == "" || options.getLanguageIndex() == 0)
    {
        loadLanguage = "harbour-money-" + QLocale::system().name();
    }
    else if (options.getLanguage() == "Português") {
        loadLanguage = "harbour-money-pt-br";
    }
    else if (options.getLanguage() == "English") {
        loadLanguage = "harbour-money-en";
    }
    else if (options.getLanguage() == "Deutsch") {
        loadLanguage = "harbour-money-de";
    }
    else if (options.getLanguage() == "Nederlands") {
        loadLanguage = "harbour-money-nl";
    }
    else if (options.getLanguage() == "Norsk Bokmål") {
        loadLanguage = "harbour-money-nb";
    }
    else {
        loadLanguage = "harbour-money-en";
    }
    qDebug() << loadLanguage;

    QTranslator translator;
    translator.load(loadLanguage,
                    "/usr/share/harbour-money/translations");
    app->installTranslator(&translator);

    QCoreApplication::setApplicationName("Money");
    QCoreApplication::setApplicationVersion("0.4.1");

    view->setSource(QUrl("qrc:/harbour-money.qml"));
    view->showFullScreen();

    return app->exec();
}

