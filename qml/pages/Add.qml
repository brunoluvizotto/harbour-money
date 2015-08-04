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

Dialog {
    id: root

    allowedOrientations: Orientation.Portrait + Orientation.Landscape + Orientation.LandscapeInverted

    property string parentKind: ""

    onAccepted:
    {
        insertItem(parentKind, textInputName.text, comboBoxCategory.value, textInputDate.text, textInputTodayDate.text, textInputValue.text.replace(",","."), comboBoxKind.value)
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

                rs = tx.executeSql('SELECT * FROM CATEGORIES ORDER BY NAME');
                for (var i = 0; i < rs.rows.length; ++i)
                {
                    categoryModel.insert(categoryModel.count, {"category":rs.rows.item(i).NAME})
                }
            }
        )
    }

    function insertItem(type, name, category, date, todayDate, value, kind)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                var englishKind;
                if (kind === appWindow.variable)
                    englishKind = appWindow.variableEng
                else if(kind === appWindow.fixed)
                    englishKind = appWindow.fixedEng
                else if(kind === appWindow.oneTime)
                    englishKind = appWindow.oneTimeEng
                var data = date.substring(6, 10) + "/" + date.substring(3, 6) + date.substring(0, 2)
                var todayData = todayDate.substring(6, 10) + "/" + todayDate.substring(3, 6) + todayDate.substring(0, 2)
                tx.executeSql('INSERT INTO ' + type + ' (NAME, CATEGORY, DATE, TODAY_DATE, VALUE, KIND) VALUES ("' + name + '", "' + category + '", "' + data + '", "' + todayData + '", ' + value + ', "' + englishKind + '")');
            }
        )
    }

    function leadZero(n) {
        return (n < 10) ? ("0" + n) : n;
    }

    Component.onCompleted:
    {
        getCategories()
    }

    PageHeader {
        id: headerTitle
        title: qsTr("Add")
    }

    SilicaFlickable {
        id: header
        anchors.top: headerTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentHeight: column.height
        //height: column.height + headerTitle.height
        //width: parent.width
        clip: true


        Column {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            //anchors.bottom: parent.bottom

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                Label {
                    id: labelName
                    text: qsTr("Name:")
                    font.pixelSize: Theme.fontSizeMedium;
                    color: Theme.primaryColor
                }
                TextField {
                    id: textInputName
                    text: ""
                    width: 0.75 * parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    maximumLength: 26
                    focus: true
                    //anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeMedium;
                }
            }

            ComboBox {
                id: comboBoxCategory
                width: parent.width
                anchors.left: parent.left
                //anchors.horizontalCenter: parent.horizontalCenter
                label: "Category"

                menu: ContextMenu {
                      Repeater {
                           model: ListModel { id: categoryModel }
                           MenuItem { text: model.category }
                      }
                 }
            }
            ComboBox {
                id: comboBoxKind
                width: parent.width
                anchors.left: parent.left
                //anchors.horizontalCenter: parent.horizontalCenter
                label: "Type"

                menu: ContextMenu {
                    MenuItem { text: appWindow.variable }
                    MenuItem { text: appWindow.fixed }
                    MenuItem { text: appWindow.oneTime }
                }
            }

            Component {
                id: pickerComponent
                DatePickerDialog {}
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                Label {
                    id: labelDate
                    text: qsTr("Date of Activity:")
                    font.pixelSize: Theme.fontSizeMedium;
                    color: Theme.primaryColor
                }
                TextField {
                    id: textInputTodayDate
                    text: Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                    maximumLength: 16
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: RegExpValidator{ regExp: /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/; }
                    width: 0.5 * parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    font.pixelSize: Theme.fontSizeMedium;
                    focusOnClick: false

                    property int lastLength: 0
                    onClicked:
                    {
                        var dialog = pageStack.push(pickerComponent, {
                                    date: options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), +1, "yyyy/MM/dd")/*Qt.formatDateTime(new Date(), "yyyy/MM/dd")*/})
                        dialog.accepted.connect(function() {
                                    text = leadZero(dialog.day) + "/" + leadZero(dialog.month) + "/" + dialog.year; focus = false})
                    }

                    /*onTextChanged:
                    {
                        if((text.length === 2 || text.length === 5) && (lastLength === 1 || lastLength === 4))
                            text += '/'
                        lastLength = text.length
                    }*/
                }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                Label {
                    id: labelTodayDate
                    text: qsTr("Date of Paying:")
                    font.pixelSize: Theme.fontSizeMedium;
                    color: Theme.primaryColor
                }
                TextField {
                    id: textInputDate
                    text: Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                    maximumLength: 16
                    inputMethodHints: Qt.ImhDigitsOnly
                    validator: RegExpValidator{ regExp: /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/; }
                    width: 0.5 * parent.width
                    horizontalAlignment: TextInput.AlignHCenter
                    font.pixelSize: Theme.fontSizeMedium;
                    focusOnClick: false

                    property int lastLength: 0
                    onClicked:
                    {
                        var dialog = pageStack.push(pickerComponent, {
                                    date: options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), +1, "yyyy/MM/dd") /*Qt.formatDateTime(new Date(), "yyyy/MM/dd")*/})
                        dialog.accepted.connect(function() {
                                    text = leadZero(dialog.day) + "/" + leadZero(dialog.month) + "/" + dialog.year; focus = false})
                    }

                    /*onTextChanged:
                    {
                        if((text.length === 2 || text.length === 5) && (lastLength === 1 || lastLength === 4))
                            text += '/'
                        lastLength = text.length
                    }*/
                }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                Label {
                    id: labelValue
                    text: qsTr("Value:")
                    font.pixelSize: Theme.fontSizeMedium;
                    color: Theme.primaryColor
                }
                TextField {
                    id: textInputValue
                    text: ""
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    width: 0.75 * parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    maximumLength: 26
                    font.pixelSize: Theme.fontSizeMedium;
                }
            }
        }
    }
}
