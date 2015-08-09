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

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../"


Page {
    id: rootPaid
    visible: true

    allowedOrientations: Orientation.Portrait + Orientation.Landscape + Orientation.LandscapeInverted

    property real totalValue: 0

    function getPaid()
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        totalValue = 0;

        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS PAID(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, NAME TEXT NOT NULL, CATEGORY TEXT, DATE TEXT NOT NULL, TODAY_DATE TEXT NOT NULL, VALUE REAL NOT NULL, KIND TEXT NOT NULL)');

                var queryType = 0;
                var datePeriod
                if(appWindow.periodShown === appWindow.today)
                    datePeriod = Qt.formatDateTime(new Date(), "yyyy/MM/dd")
                else if(appWindow.periodShown === appWindow.last3Days)
                {
                    datePeriod = options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -3, "yyyy/MM/dd")
                    queryType = 1
                }
                else if(appWindow.periodShown === appWindow.last7Days)
                {
                    datePeriod = options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -7, "yyyy/MM/dd")
                    queryType = 1
                }
                else if(appWindow.periodShown === appWindow.last15Days)
                {
                    datePeriod = options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -15, "yyyy/MM/dd")
                    queryType = 1
                }
                else if(appWindow.periodShown === appWindow.last30Days)
                {
                    datePeriod = options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -30, "yyyy/MM/dd")
                    queryType = 1
                }
                else if(appWindow.periodShown === appWindow.thisMonth)
                    datePeriod = Qt.formatDateTime(new Date(), "yyyy/MM/__")
                else if(appWindow.periodShown === appWindow.thisYear)
                    datePeriod = Qt.formatDateTime(new Date(), "yyyy/__/__")
                else if(appWindow.periodShown === appWindow.eternity)
                    datePeriod = Qt.formatDateTime(new Date(), "____/__/__")
                else
                    datePeriod = Qt.formatDateTime(new Date(), "yyyy/MM/dd")

                paidModel.clear();
                var rs;
                if(!queryType)
                    rs = tx.executeSql('SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.TODAY_DATE, PAID.VALUE, PAID.KIND FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME AND PAID.DATE LIKE "' + datePeriod + '" ORDER BY PAID.DATE');
                else
                    rs = tx.executeSql('SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.TODAY_DATE, PAID.VALUE, PAID.KIND FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME AND PAID.DATE > "' + datePeriod + '" ORDER BY PAID.DATE');
                for (var i = 0; i < rs.rows.length; ++i)
                {
                    var kindLanguage;
                    if (rs.rows.item(i).KIND === "Variable")
                        kindLanguage = appWindow.variable
                    if (rs.rows.item(i).KIND === "Fixed")
                        kindLanguage = appWindow.fixed
                    if (rs.rows.item(i).KIND === "One Time")
                        kindLanguage = appWindow.oneTime

                    totalValue += rs.rows.item(i).VALUE;
                    var data = rs.rows.item(i).DATE.substring(8, 10) + "/" + rs.rows.item(i).DATE.substring(5, 8) + rs.rows.item(i).DATE.substring(0, 4)
                    var todayDate = rs.rows.item(i).TODAY_DATE.substring(8, 10) + "/" + rs.rows.item(i).TODAY_DATE.substring(5, 8) + rs.rows.item(i).TODAY_DATE.substring(0, 4)
                    paidModel.insert(paidModel.count, {"name":rs.rows.item(i).NAME, "category":rs.rows.item(i).CATEGORY, "datePaid":data, "todayDate":todayDate, "value":rs.rows.item(i).VALUE, "kind":kindLanguage})
                }
                appWindow.paidTotal = totalValue
            }
        )
    }

    function insertItem(type, name, category, date, todayDate, value, kind)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                var data = date.substring(6, 10) + "/" + date.substring(3, 6) + date.substring(0, 2)
                var todayData = todayDate.substring(6, 10) + "/" + todayDate.substring(3, 6) + todayDate.substring(0, 2)
                tx.executeSql('INSERT INTO ' + type + ' (NAME, CATEGORY, DATE, TODAY_DATE, VALUE, KIND) VALUES ("' + name + '", "' + category + '", "' + data + '", "' + todayData + '", ' + value + ', "' + kind + '")');
            }
        )
    }

    function setToPay(name, category, date, todayDate, value, kind)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                var kindLanguage;
                if (kind === appWindow.variable)
                    kindLanguage = appWindow.variableEng
                if (kind === appWindow.fixed)
                    kindLanguage = appWindow.fixedEng
                if (kind === appWindow.oneTime)
                    kindLanguage = appWindow.oneTimeEng

                var data = date.substring(6, 10) + "/" + date.substring(3, 6) + date.substring(0, 2)
                var todayData = todayDate.substring(6, 10) + "/" + todayDate.substring(3, 6) + todayDate.substring(0, 2)
                var rs = tx.executeSql('DELETE FROM PAID WHERE NAME = "' + name + '" AND CATEGORY = "' + category + '" AND DATE = "' + data + '" AND TODAY_DATE = "' + todayData + '" AND VALUE = ' + value + ' AND KIND = "' + kindLanguage + '"')//'SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.VALUE, CATEGORIES.ICON FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME ORDER BY PAID.DATE');
                getPaid();
                tx.executeSql('CREATE TABLE IF NOT EXISTS TO_PAY(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, NAME TEXT NOT NULL, CATEGORY TEXT, DATE TEXT NOT NULL, TODAY_DATE TEXT NOT NULL, VALUE REAL NOT NULL, KIND TEXT NOT NULL)');
                insertItem("TO_PAY", name, category, date, todayDate, value, kindLanguage)
            }
        )
    }

    function delItem(name, category, date, todayDate, value, kind)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                var data = date.substring(6, 10) + "/" + date.substring(3, 6) + date.substring(0, 2)
                var todayData = todayDate.substring(6, 10) + "/" + todayDate.substring(3, 6) + todayDate.substring(0, 2)
                console.log('DELETE FROM PAID WHERE NAME = "' + name + '" AND CATEGORY = "' + category + '" AND DATE = "' + data + '" AND TODAY_DATE = "' + todayData + '" AND VALUE = ' + value + ' AND KIND = "' + kind + '"')
                var rs = tx.executeSql('DELETE FROM PAID WHERE NAME = "' + name + '" AND CATEGORY = "' + category + '" AND DATE = "' + data + '" AND TODAY_DATE = "' + todayData + '" AND VALUE = ' + value + ' AND KIND = "' + kind + '"') //'SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.VALUE, CATEGORIES.ICON FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME ORDER BY PAID.DATE');
            }
        )
    }

    function getCategories()
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS CATEGORIES(NAME TEXT NOT NULL UNIQUE)');

                //categoryModel.clear();
                var rs = tx.executeSql('SELECT * FROM CATEGORIES ORDER BY NAME');
                if(rs.rows.length === 0)
                {
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Bar")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Bill")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Cleaning")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Fuel")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Grocery")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Leisure")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Parking")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Restaurant")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Snack")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Tax")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Transport")');
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("Other")');
                }
            }
        )
    }

    function dropTable(table)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                var rs = tx.executeSql('DROP TABLE ' + table)
            }
        )
    }

    Component.onCompleted:
    {
        timerPush.start()
    }

    onStatusChanged:
    {
        if (status === PageStatus.Active) {
            getCategories();
            getPaid();
        }
    }

    Timer {
        id: timerPush
        interval: 5
        onTriggered:
        {
            pageStack.pushAttached(Qt.resolvedUrl("ToPay.qml"))
            pageStack.navigateForward()
            pageStack.completeAnimation()
            pageStack.navigateBack()
            pageStack.completeAnimation()
        }
    }

    SilicaFlickable {
        id: header
        height: parent.height
        width: parent.width

        PageHeader {
            id: headerTitle
            title: qsTr("Paid")
        }
        Label {
            id: intervalLabel
            text: options.paidPeriod
            anchors.verticalCenter: headerTitle.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Options.qml"))
            }
            MenuItem {
                text: qsTr("Stats")
                onClicked: pageStack.push(Qt.resolvedUrl("Stats.qml"))
            }
            MenuItem {
                text: qsTr("Add")
                onClicked:
                {
                    var dialog = pageStack.push("Add.qml", {"parentKind": "PAID"})
                    dialog.accepted.connect( function() {getPaid()} )
                }
            }
        }

        Rectangle {
            id: rectangleData
            color: "transparent"

            anchors {
                top: headerTitle.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }

            ListModel {
                id: paidModel
            }

            Component {
                id: paidDelegate

                ListItem {
                    id: container
                    contentHeight: textAltura.height + dateTodayText.height + dateToPayText.height + valueText.height //1.7 * iconImage.height // 2.5 * textAltura.height
                    width: ListView.view.width;
                    menu: contextMenu

                    Rectangle {
                        id: containerRectangle
                        color: "transparent"
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                            leftMargin: Theme.paddingSmall
                            rightMargin: Theme.paddingSmall
                        }

                        Text {
                            id: textFirstLetter
                            text: category.substring(0, 1)
                            height: 2 * textAltura.height
                            horizontalAlignment: Text.AlignHCenter
                            width: height * 0.8
                            font.pixelSize: 2 * Theme.fontSizeExtraLarge
                            anchors.top: parent.top
                            anchors.topMargin: 12
                            anchors.left: parent.left
                            anchors.leftMargin: textAltura.anchors.leftMargin
                            color: Theme.secondaryColor;
                        }

                        Text {
                            id: textAltura;
                            text: name;
                            font.pixelSize: Theme.fontSizeLarge;
                            font.family: Theme.fontFamily
                            anchors.top: parent.top
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.secondaryColor;
                        }
                        Text {
                            id:categoryText
                            text: category
                            font.pixelSize: Theme.fontSizeSmall;
                            font.family: Theme.fontFamily
                            anchors.bottom: valueText.bottom
                            anchors.horizontalCenter: textFirstLetter.horizontalCenter
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateTodayText
                            text: qsTr("Act. Date: ") + todayDate;
                            font.pixelSize: Theme.fontSizeMedium;
                            font.family: Theme.fontFamily
                            anchors.top: textAltura.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateToPayText
                            text: qsTr("Paym. Date: ") + datePaid;
                            font.pixelSize: Theme.fontSizeMedium;
                            font.family: Theme.fontFamily
                            anchors.top: dateTodayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: valueText
                            text: (options.currencyBefore ? (options.currency + " ") : "") + value.toFixed(2).replace(".",",") + (!options.currencyBefore ? (" " + options.currency) : "");
                            font.pixelSize: Theme.fontSizeMedium;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: kindText
                            text: kind;
                            font.pixelSize: Theme.fontSizeMedium;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 30
                            color: Theme.primaryColor;
                        }

                        RemorseItem { id: deleteRemorseItem }
                        function deleteRemorse() {

                            deleteRemorseItem.execute(container, qsTr("Deleting"),
                                                          function() {
                                                              var kindLanguage;
                                                              if (paidModel.get(index).kind === appWindow.variable)
                                                                  kindLanguage = appWindow.variableEng
                                                              if (paidModel.get(index).kind === appWindow.fixed)
                                                                  kindLanguage = appWindow.fixedEng
                                                              if (paidModel.get(index).kind === appWindow.oneTime)
                                                                  kindLanguage = appWindow.oneTimeEng

                                                              delItem(paidModel.get(index).name, paidModel.get(index).category, paidModel.get(index).datePaid, paidModel.get(index).todayDate, paidModel.get(index).value, kindLanguage)
                                                              paidModel.remove(index)
                                                          })
                        }

                        Component {
                            id: contextMenu

                            ContextMenu {
                                anchors.horizontalCenter: container.horizontalCenter

                                MenuItem {
                                    text: qsTr("Set To Pay")
                                    onClicked: {
                                        setToPay(paidModel.get(index).name, paidModel.get(index).category, paidModel.get(index).datePaid, paidModel.get(index).todayDate, paidModel.get(index).value, paidModel.get(index).kind)
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Edit")
                                    onClicked: {
                                        var kindIndex;
                                        if (paidModel.get(index).kind === appWindow.variable)
                                            kindIndex = 0
                                        else if (paidModel.get(index).kind === appWindow.fixed)
                                            kindIndex = 1
                                        else if (paidModel.get(index).kind === appWindow.oneTime)
                                            kindIndex = 2
                                        var dialog = pageStack.push("EditDialog.qml", {"parentKind": "PAID", "nameOld": paidModel.get(index).name, "categoryOld": paidModel.get(index).category, "dateOld": paidModel.get(index).datePaid, "todayDateOld": paidModel.get(index).todayDate, "valueOld": paidModel.get(index).value, "kindOldIndex": kindIndex})
                                        dialog.accepted.connect( function() {getPaid()} )
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Delete")
                                    onClicked: {
                                        containerRectangle.deleteRemorse();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            SilicaListView {
                id: paidListView
                spacing: 8
                anchors {
                    top: parent.top
                    bottom: textTotal.top
                    left: parent.left
                    right: parent.right
                    margins: 4
                }
                clip: true
                model: paidModel
                delegate: paidDelegate
                focus: true
            }

            Text {
                id: textTotal
                text: "Total: " + (options.currencyBefore ? (options.currency + " ") : "") + totalValue.toFixed(2).replace(".",",").toString() + (!options.currencyBefore ? (" " + options.currency) : "") // (Math.round(parseFloat(totalValue) * 100) / 100)
                height: 60
                anchors.bottomMargin: Theme.paddingMedium
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
}


