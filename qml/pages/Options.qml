import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

Page {
    id: rootOptions
    visible: true

    property string other: qsTr("Other")

    allowedOrientations: Orientation.Portrait + Orientation.Landscape + Orientation.LandscapeInverted

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

                categoriesModel.clear();
                rs = tx.executeSql('SELECT * FROM CATEGORIES ORDER BY NAME');
                for (var i = 0; i < rs.rows.length; ++i)
                {
                    categoriesModel.insert(categoriesModel.count, {"category":rs.rows.item(i).NAME})
                }
            }
        )
    }

    function checkOtherCategory()
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                var rs = tx.executeSql('SELECT * FROM CATEGORIES WHERE NAME = "' + other + '"');
                if (!rs.rows.length)
                {
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("' + other + '")');
                }
            }
        )
    }

    function addCategory(category)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                if(category)
                {
                    tx.executeSql('INSERT INTO CATEGORIES VALUES ("' + category + '")');
                    getCategories();
                }
            }
        )
    }

    function delCategory(category)
    {

        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                tx.executeSql('UPDATE PAID SET CATEGORY = "' + other + '" WHERE CATEGORY = "' + category + '"');
                tx.executeSql('UPDATE TO_PAY SET CATEGORY = "' + other + '" WHERE CATEGORY = "' + category + '"');
                tx.executeSql('DELETE FROM CATEGORIES WHERE NAME = "' + category + '"');
                //getCategories();
            }
        )
    }

    onStatusChanged:
    {
        if (status === PageStatus.Active) {
            getCategories();
        }
    }

    PageHeader {
        id: headerTitle
        title: qsTr("Settings")
    }

    SilicaFlickable {
        anchors.top: headerTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        contentHeight: column.height
        clip: true

        Column {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            //anchors.bottom: parent.bottom

            SectionHeader {
                text: qsTr("Paid")
            }
            ComboBox {
                id: comboBoxPeriod
                width: parent.width
                anchors.left: parent.left
                label: qsTr("Interval Shown")
                //currentIndex: options.paidPeriodIndex

                menu: ContextMenu {
                    id: periodModel
                    MenuItem { text: appWindow.today }
                    MenuItem { text: appWindow.last3Days }
                    MenuItem { text: appWindow.last7Days }
                    MenuItem { text: appWindow.last15Days }
                    MenuItem { text: appWindow.last30Days }
                    MenuItem { text: appWindow.thisMonth }
                    MenuItem { text: appWindow.thisYear }
                    MenuItem { text: appWindow.eternity }
                }
                onCurrentIndexChanged:
                {
                    options.paidPeriodIndex = currentIndex
                }

                onValueChanged:
                {
                    options.paidPeriod = value
                    appWindow.periodShown = value
                }
                Component.onCompleted:
                {
                    currentIndex = options.paidPeriodIndex
                    getCategories()
                }
            }

            SectionHeader {
                text: qsTr("Stats - All Categories")
            }
            TextField {
                id: textFieldTarget
                label: qsTr("Target - Variable (Month)")
                width: rootOptions.width * 0.8
                placeholderText: label
                Component.onCompleted:
                {
                    text = parseFloat(options.target)
                }
                onTextChanged: options.target = text
            }
            TextField {
                id: textFieldDaysShow
                label: qsTr("Days to show")
                text: parseInt(options.daysStat)
                width: rootOptions.width * 0.8
                placeholderText: label
                onTextChanged: options.daysStat = text
            }
            TextField {
                id: textFieldMonthsShow
                label: qsTr("Months to show")
                text: parseInt(options.monthsStat)
                width: rootOptions.width * 0.8
                placeholderText: label
                onTextChanged: options.monthsStat = text
            }
            TextField {
                id: textCurrency
                label: qsTr("Currency")
                text: options.currency
                width: rootOptions.width * 0.8
                placeholderText: label
                onTextChanged: options.currency = text
            }
            TextSwitch {
                id: switchCurrencyBefore
                text: qsTr("Before")
                checked: options.currencyBefore
                automaticCheck: false
                onClicked:
                {
                    options.currencyBefore = true;
                }
            }
            TextSwitch {
                id: switchCurrencyBefore2
                text: qsTr("After")
                checked: !options.currencyBefore
                automaticCheck: false
                onClicked:
                {
                    options.currencyBefore = false;
                }
            }

            SectionHeader {
                text: qsTr("Stats - Single Category")
            }
            TextSwitch {
                id: switchPeriodDays
                text: qsTr("Days")
                checked: options.categoryPeriod === "Days" ? true : false
                automaticCheck: false
                onClicked:
                {
                    if(checked)
                    {

                    }
                    else
                    {
                        options.categoryPeriod = "Days";
                    }
                }
            }
            TextSwitch {
                id: switchPeriodMonths
                text: qsTr("Months")
                checked: options.categoryPeriod === "Months" ? true : false
                automaticCheck: false
                onClicked:
                {
                    if(checked)
                    {

                    }
                    else
                    {
                        options.categoryPeriod = "Months";
                        //bestof = 5;
                    }
                }
            }

            TextField {
                id: textFieldCategoryPeriod
                label: (options.categoryPeriod === "Months" ? switchPeriodMonths.text : switchPeriodDays.text) + qsTr(" to show")
                text: parseInt(options.categoriesStat)
                width: rootOptions.width * 0.8
                placeholderText: options.categoryPeriod + qsTr(" to show")
                onTextChanged: options.categoriesStat = text
            }

            SectionHeader {
                text: qsTr("Language")
            }

            ComboBox {
                id: comboBoxLanguage
                width: parent.width
                anchors.left: parent.left
                label: qsTr("Language")
                currentIndex: options.languageIndex

                menu: ContextMenu {
                    id: languageModel
                    MenuItem { text: qsTr("System Locale") }
                    MenuItem { text: "Deutsch" }
                    MenuItem { text: "English" }
                    MenuItem { text: "Nederlands" }
                    MenuItem { text: "Norsk Bokmål" }
                    MenuItem { text: "Português" }
                    MenuItem { text: "Pусский" }
                }
                onCurrentIndexChanged:
                {
                    options.languageIndex = currentIndex
                }

                onValueChanged:
                {
                    options.language = value
                }
            }

            SectionHeader {
                text: qsTr("Categories")
            }

            TextField {
                id: textFieldNewCategory
                label: qsTr("Category Name")
                text: ""
                maximumLength: 12
                width: parent.width * 0.8
                placeholderText: label
            }

            Button {
                text: qsTr("Add New Category")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked:
                {
                    addCategory(textFieldNewCategory.text)
                }
            }

            ListModel {
                id: categoriesModel
            }
            Component {
                id: categoriesDelegate
                ListItem {
                    id: container
                    contentHeight: categoryText.height
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
                            id: categoryText
                            text: category
                            horizontalAlignment: Text.AlignHCenter
                            height: Theme.itemSizeSmall
                            width: parent.width
                            font.pixelSize: Theme.fontSizeMedium
                            anchors.top: parent.top
                            anchors.topMargin: 12
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            color: container.highlighted ? Theme.highlightColor : Theme.primaryColor;
                        }


                        /*function deleteRemorse() {
                            remorseAction(qsTr("Delete", "Delete item"),
                            function() {
                                if(categoriesModel.get(index).category !== "Other")
                                    delCategory(categoriesModel.get(index).category)
                            })
                        }*/

                        RemorseItem { id: deleteRemorseItem }
                        function deleteRemorse() {

                            deleteRemorseItem.execute(container, qsTr("Deleting"),
                                                          function() {
                                                              checkOtherCategory();
                                                              if(categoriesModel.get(index).category !== other)
                                                              {
                                                                  delCategory(categoriesModel.get(index).category)
                                                                  categoriesModel.remove(index)
                                                              }
                                                          })
                        }

                        Component {
                            id: contextMenu
                            ContextMenu {
                                anchors.horizontalCenter: container.horizontalCenter
                                MenuItem {
                                    text: qsTr("Edit")
                                    onClicked: {
                                        var dialog = pageStack.push("EditCategoryDialog.qml", {"oldCategory": categoriesModel.get(index).category})
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Delete")
                                    onClicked: {
                                        containerRectangle.deleteRemorse()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            SilicaListView {
                id: categoriesListView
                height: 500
                spacing: 4
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
                clip: true
                model: categoriesModel
                delegate: categoriesDelegate
                focus: true
                //Behavior on height { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 250; } }
            }
        }
    }
}
