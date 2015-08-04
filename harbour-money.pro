# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-money

CONFIG += sailfishapp

SOURCES += src/harbour-money.cpp \
    src/options.cpp

OTHER_FILES += \
    rpm/harbour-money.changes.in \
    rpm/harbour-money.spec \
    rpm/harbour-money.yaml \
    #translations/*.ts \
    harbour-money.desktop \
    translations/harbour-money-English.ts \
    translations/harbour-money-Portugues.ts \

#i18n.path = /usr/share/harbour-money/translations
#i18n.files = translations/harbour-money-Portugues.qm \
#    translations/harbour-money-English.qm

#INSTALLS += i18n

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/harbour-money-Deutsch.ts
TRANSLATIONS += translations/harbour-money-pt-br.ts
TRANSLATIONS += translations/harbour-money-en.ts

HEADERS += \
    src/options.h

RESOURCES += \
    qml/res.qrc

