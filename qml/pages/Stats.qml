import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../elements"
import "../"

Page {
    id: rootStats
    visible: true

    property int state: status
    property var valuesTest: []
    property bool editingFetchDB: false
    property bool editingPaidCategory: false

    allowedOrientations: Orientation.Portrait + Orientation.Landscape + Orientation.LandscapeInverted

    onStateChanged:
    {
        if(state === 2)
        {
            if(!categoryModel.count)
                getCategories();
            getPaid(options.daysStat);
            getPaidMonths(options.monthsStat);
            if(editingPaidCategory)
            {
                getPaidCategory(options.categoryPeriod, options.categoriesStat, comboBoxCategory.value)
                editingPaidCategory = false;
            }
            if(editingFetchDB)
            {
                fetchDB();
                editingFetchDB = false;
            }
        }
    }

    function delItem(name, category, date, todayDate, value, kind)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                var data = date.substring(6, 10) + "/" + date.substring(3, 6) + date.substring(0, 2)
                var todayData = todayDate.substring(6, 10) + "/" + todayDate.substring(3, 6) + todayDate.substring(0, 2)
                var rs = tx.executeSql('DELETE FROM PAID WHERE NAME = "' + name + '" AND CATEGORY = "' + category + '" AND DATE = "' + data + '" AND TODAY_DATE = "' + todayData + '" AND VALUE = ' + value + ' AND KIND = "' + kind + '"')//'SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.VALUE, CATEGORIES.ICON FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME ORDER BY PAID.DATE');
            }
        )
    }

    Timer {
        id: timeInit
        interval: 25
        onTriggered:
        {
            comboBoxCategory.currentIndex = options.lastCategoryStats
            comboBoxCategory.enabled = true
            getPaidCategory(options.categoryPeriod, options.categoriesStat, comboBoxCategory.value)
            //console.log(comboBoxCategory.value)
        }
    }

    SilicaFlickable {
        id: header
        //height: parent.height
        //width: parent.width
        anchors {
            fill: parent
            //topMargin: controlPanel.visibleSize
        }

        contentHeight: column.height + headerTitle.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Options.qml"))
            }
        }

        PageHeader {
            id: headerTitle
            title: qsTr("Stats")
        }

        Column {
            id: column
            anchors.top: headerTitle.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.paddingSmall
            //anchors.bottom: parent.bottom

            /*Button {
                text: controlPanel.open ? "Close Category Panel" : "Open Category Panel"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: controlPanel.open = !controlPanel.open
            }*/

            ComboBox {
                id: comboBoxKind
                width: parent.width
                anchors.left: parent.left
                label: qsTr("Type")

                menu: ContextMenu {
                    MenuItem { text: appWindow.variable }
                    MenuItem { text: appWindow.fixed }
                    MenuItem { text: appWindow.oneTime }
                    MenuItem { text: qsTr("All Types") }
                }
                onValueChanged:
                {
                    getPaid(options.daysStat);
                    getPaidMonths(options.monthsStat);
                }
            }
            Label {
                id: lastXDays
                text: qsTr("Last ") + barGraphDays.values.length + qsTr(" days")
                anchors.horizontalCenter: parent.horizontalCenter
            }
            BarGraph {
                id: barGraphDays
                height: 200
                width: 1 * rootStats.width
                anchors.horizontalCenter: parent.horizontalCenter
                //values: valuesTest//[1200, 2800, 2505.45, 2000, 3000, 1000, 1500, 2460, 1800]
                xLabels: ["J", "F", "M", "A", "M"]
                yLabel: options.currency
                target: comboBoxKind.value === qsTr("Variable") ? options.target / 30 : 0
                //repeaterSpacing: 6

                yAxisMax: 3000
                yAxisMin: 1000
            }
            TextSwitch {
                id: textSwitchShowActivitiesDays
                text: qsTr("Show Activities")
                anchors.left: parent.left
            }
            ListModel {
                id: activitiesDaysModel
            }
            Component {
                id: activitiesDaysDelegate
                ListItem {
                    id: container
                    contentHeight: textAltura.height + dateTodayText.height + dateToPayText.height + valueText.height //1.7 * iconImage.height // 2.5 * textAltura.height
                    width: ListView.view.width;
                    menu: contextMenu

                    function deleteRemorseDays() {
                        remorseAction(qsTr("Delete", "Delete item"),
                        function() {
                            delItem(activitiesDaysModel.get(index).name, activitiesDaysModel.get(index).category, activitiesDaysModel.get(index).datePaid, activitiesDaysModel.get(index).todayDate, activitiesDaysModel.get(index).value, activitiesDaysModel.get(index).kind)
                            getPaid(options.daysStat);
                        })
                    }

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
                            width: height
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
                            font.pixelSize: Theme.fontSizeMedium;
                            font.family: Theme.fontFamily
                            anchors.bottom: valueText.bottom
                            anchors.horizontalCenter: textFirstLetter.horizontalCenter
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateTodayText
                            text: qsTr("Act. Date: ") + todayDate;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: textAltura.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateToPayText
                            text: qsTr("Paym. Date: ") + datePaid;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateTodayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: valueText
                            text: (options.currencyBefore ? (options.currency + " ") : "") + value.toFixed(2).replace(".",",") + (!options.currencyBefore ? (" " + options.currency) : "");
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: kindText
                            text: kind;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 30
                            color: Theme.primaryColor;
                        }

                        Component {
                            id: contextMenu
                            ContextMenu {
                                anchors.horizontalCenter: container.horizontalCenter

                                MenuItem {
                                    text: qsTr("Edit")
                                    onClicked: {
                                        var kindIndex;
                                        if (activitiesDaysModel.get(index).kind === "Variable")
                                            kindIndex = 0
                                        else if (activitiesDaysModel.get(index).kind === "Fixed")
                                            kindIndex = 1
                                        else if (activitiesDaysModel.get(index).kind === "One Time")
                                            kindIndex = 2
                                        var dialog = pageStack.push("EditDialog.qml", {"parentKind": "PAID", "nameOld": activitiesDaysModel.get(index).name, "categoryOld": activitiesDaysModel.get(index).category, "dateOld": activitiesDaysModel.get(index).datePaid, "todayDateOld": activitiesDaysModel.get(index).todayDate, "valueOld": activitiesDaysModel.get(index).value, "kindOldIndex": kindIndex})
                                        dialog.accepted.connect( function() {getPaid(options.daysStat)} )
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Delete")
                                    onClicked: {
                                        deleteRemorseDays();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            SilicaListView {
                id: activitiesDaysListView
                height: textSwitchShowActivitiesDays.checked ? rootStats.height / 2  : 0;
                spacing: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
                clip: true
                model: activitiesDaysModel
                delegate: activitiesDaysDelegate
                focus: true
                Behavior on height { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 250; } }
            }

            Label {
                id: lastXMonths
                text: qsTr("Last ") + barGraphDays.values.length + qsTr(" months")
                anchors.horizontalCenter: parent.horizontalCenter
            }
            BarGraph {
                id: barGraphMonths
                height: 200
                width: 1 * rootStats.width
                anchors.horizontalCenter: parent.horizontalCenter
                //values: valuesTest//[1200, 2800, 2505.45, 2000, 3000, 1000, 1500, 2460, 1800]
                xLabels: ["J", "F", "M", "A", "M"]
                yLabel: options.currency
                target: comboBoxKind.value === qsTr("Variable") ? options.target : 0

                yAxisMax: 3000
                yAxisMin: 1000
            }
            TextSwitch {
                id: textSwitchShowActivitiesMonths
                text: qsTr("Show Activities")
                anchors.left: parent.left
            }
            ListModel {
                id: activitiesMonthsModel
            }
            Component {
                id: activitiesMonthsDelegate
                ListItem {
                    id: container
                    contentHeight: textAltura.height + dateTodayText.height + dateToPayText.height + valueText.height //1.7 * iconImage.height // 2.5 * textAltura.height
                    width: ListView.view.width;
                    menu: contextMenu

                    function deleteRemorseMonths() {
                        remorseAction(qsTr("Delete", "Delete item"),
                        function() {
                            delItem(activitiesMonthsModel.get(index).name, activitiesMonthsModel.get(index).category, activitiesMonthsModel.get(index).datePaid, activitiesMonthsModel.get(index).todayDate, activitiesMonthsModel.get(index).value, activitiesMonthsModel.get(index).kind)
                            getPaidMonths(options.monthsStat);
                        })
                    }

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
                            width: height
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
                            font.pixelSize: Theme.fontSizeMedium;
                            font.family: Theme.fontFamily
                            anchors.bottom: valueText.bottom
                            anchors.horizontalCenter: textFirstLetter.horizontalCenter
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateTodayText
                            text: qsTr("Act. Date: ") + todayDate;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: textAltura.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateToPayText
                            text: qsTr("Paym. Date: ") + datePaid;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateTodayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: valueText
                            text: (options.currencyBefore ? (options.currency + " ") : "") + value.toFixed(2).replace(".",",") + (!options.currencyBefore ? (" " + options.currency) : "");
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: kindText
                            text: kind;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 30
                            color: Theme.primaryColor;
                        }

                        Component {
                            id: contextMenu
                            ContextMenu {
                                anchors.horizontalCenter: container.horizontalCenter

                                MenuItem {
                                    text: qsTr("Edit")
                                    onClicked: {
                                        var kindIndex;
                                        if (activitiesMonthsModel.get(index).kind === "Variable")
                                            kindIndex = 0
                                        else if (activitiesMonthsModel.get(index).kind === "Fixed")
                                            kindIndex = 1
                                        else if (activitiesMonthsModel.get(index).kind === "One Time")
                                            kindIndex = 2
                                        var dialog = pageStack.push("EditDialog.qml", {"parentKind": "PAID", "nameOld": activitiesMonthsModel.get(index).name, "categoryOld": activitiesMonthsModel.get(index).category, "dateOld": activitiesMonthsModel.get(index).datePaid, "todayDateOld": activitiesMonthsModel.get(index).todayDate, "valueOld": activitiesMonthsModel.get(index).value, "kindOldIndex": kindIndex})
                                        dialog.accepted.connect( function() {getPaidMonths(options.monthsStat)} )
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Delete")
                                    onClicked: {
                                        deleteRemorseMonths();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            SilicaListView {
                id: activitiesMonthsListView
                height: textSwitchShowActivitiesMonths.checked ? rootStats.height / 2  : 0;
                spacing: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
                clip: true
                model: activitiesMonthsModel
                delegate: activitiesMonthsDelegate
                focus: true
                Behavior on height { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 250; } }
            }

            Separator {
                width: parent.width
                color: Theme.secondaryColor
            }

            ComboBox {
                id: comboBoxCategory
                width: parent.width
                anchors.left: parent.left
                label: qsTr("Category")

                menu: ContextMenu {
                      Repeater {
                           model: ListModel { id: categoryModel }
                           MenuItem { text: model.category }
                      }
                 }

                enabled: false
                onEnabledChanged:
                {
                    getPaidCategory(options.categoryPeriod, options.categoriesStat, comboBoxCategory.value)
                }

                onValueChanged:
                {
                    if(enabled)
                    {
                        getPaidCategory(options.categoryPeriod, options.categoriesStat, comboBoxCategory.value)
                    }
                }
                onCurrentIndexChanged:
                {
                    if(enabled)
                        options.lastCategoryStats = currentIndex
                    //console.log(options.lastCategoryStats)
                }
            }

            Label {
                id: lastXInterval
                text: qsTr("Last ") + barGraphDays.values.length + " " + (options.categoryPeriod === "Months" ? appWindow.months : appWindow.days)
                anchors.horizontalCenter: parent.horizontalCenter
                Component.onCompleted: {
                    console.log(options.categoryPeriod + " = Months?")
                    console.log(options.categoryPeriod === "Months" ? appWindow.months : appWindow.days)
                }
            }

            BarGraph {
                id: barGraphCategory
                height: 200
                width: 1 * rootStats.width
                anchors.horizontalCenter: parent.horizontalCenter
                //values: valuesTest//[1200, 2800, 2505.45, 2000, 3000, 1000, 1500, 2460, 1800]
                xLabels: ["J", "F", "M", "A", "M"]
                yLabel: options.currency

                yAxisMax: 3000
                yAxisMin: 1000
            }
            TextSwitch {
                id: textSwitchShowActivitiesCategories
                text: qsTr("Show Activities")
                anchors.left: parent.left
            }
            ListModel {
                id: activitiesCategoriesModel
            }
            Component {
                id: activitiesCategoriesDelegate
                ListItem {
                    id: container
                    contentHeight: textAltura.height + dateTodayText.height + dateToPayText.height + valueText.height //1.7 * iconImage.height // 2.5 * textAltura.height
                    width: ListView.view.width;
                    menu: contextMenu

                    function deleteRemorseCategories() {
                        remorseAction(qsTr("Delete", "Delete item"),
                        function() {
                            delItem(activitiesCategoriesModel.get(index).name, activitiesCategoriesModel.get(index).category, activitiesDaysModel.get(index).datePaid, activitiesCategoriesModel.get(index).todayDate, activitiesCategoriesModel.get(index).value, activitiesCategoriesModel.get(index).kind)
                            getPaidCategory(options.categoryPeriod, options.categoriesStat, comboBoxCategory.value)
                        })
                    }

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
                            width: height
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
                            font.pixelSize: Theme.fontSizeMedium;
                            font.family: Theme.fontFamily
                            anchors.bottom: valueText.bottom
                            anchors.horizontalCenter: textFirstLetter.horizontalCenter
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateTodayText
                            text: qsTr("Act. Date: ") + todayDate;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: textAltura.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateToPayText
                            text: qsTr("Paym. Date: ") + datePaid;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateTodayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: valueText
                            text: (options.currencyBefore ? (options.currency + " ") : "") + value.toFixed(2).replace(".",",") + (!options.currencyBefore ? (" " + options.currency) : "");
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: kindText
                            text: kind;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 30
                            color: Theme.primaryColor;
                        }

                        Component {
                            id: contextMenu
                            ContextMenu {
                                anchors.horizontalCenter: container.horizontalCenter

                                MenuItem {
                                    text: qsTr("Edit")
                                    onClicked: {
                                        editingPaidCategory = true;
                                        var kindIndex;
                                        if (activitiesCategoriesModel.get(index).kind === "Variable")
                                            kindIndex = 0
                                        else if (activitiesCategoriesModel.get(index).kind === "Fixed")
                                            kindIndex = 1
                                        else if (activitiesCategoriesModel.get(index).kind === "One Time")
                                            kindIndex = 2
                                        var dialog = pageStack.push("EditDialog.qml", {"parentKind": "PAID", "nameOld": activitiesCategoriesModel.get(index).name, "categoryOld": activitiesCategoriesModel.get(index).category, "dateOld": activitiesCategoriesModel.get(index).datePaid, "todayDateOld": activitiesCategoriesModel.get(index).todayDate, "valueOld": activitiesCategoriesModel.get(index).value, "kindOldIndex": kindIndex})
                                        //dialog.accepted.connect( function() {getPaidCategory(categoryPeriodProperty, categoryiesStatProperty, categoryCombo);} )
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Delete")
                                    onClicked: {
                                        deleteRemorseCategories();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            SilicaListView {
                id: activitiesCategoriesListView
                height: textSwitchShowActivitiesCategories.checked ? rootStats.height / 2  : 0;
                spacing: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
                clip: true
                model: activitiesCategoriesModel
                delegate: activitiesCategoriesDelegate
                focus: true
                Behavior on height { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 250; } }
            }

            Separator {
                width: parent.width
                color: Theme.secondaryColor
            }

            Label {
                id: fetchDatabase
                text: qsTr("Fetch Database")
                anchors.horizontalCenter: parent.horizontalCenter
            }
            TextField {
                id: textInputName
                text: ""
                label: qsTr("Activity Name")
                placeholderText: label
                width: 0.75 * parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: TextInput.AlignHCenter
                maximumLength: 26
                focus: true
                //anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeMedium;
            }
            Component {
                id: pickerComponent
                DatePickerDialog {}
            }
            TextField {
                id: textInputDateFrom
                text: Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                label: qsTr("From")
                maximumLength: 16
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegExpValidator{ regExp: /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/; }
                width: 0.75 * parent.width
                anchors.horizontalCenter: parent.horizontalCenter
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
            }
            TextField {
                id: textInputDateTo
                text: Qt.formatDateTime(new Date(), "dd/MM/yyyy")
                label: qsTr("To")
                maximumLength: 16
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegExpValidator{ regExp: /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/; }
                width: 0.75 * parent.width
                anchors.horizontalCenter: parent.horizontalCenter
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
            }
            ListModel {
                id: activitiesFetchModel
            }
            Component {
                id: activitiesFetchDelegate
                ListItem {
                    id: container
                    contentHeight: textAltura.height + dateTodayText.height + dateToPayText.height + valueText.height //1.7 * iconImage.height // 2.5 * textAltura.height
                    width: ListView.view.width;
                    menu: contextMenu

                    function deleteRemorseFetch() {
                        remorseAction(qsTr("Delete", "Delete item"),
                        function() {
                            delItem(activitiesFetchModel.get(index).name, activitiesFetchModel.get(index).category, activitiesFetchModel.get(index).datePaid, activitiesFetchModel.get(index).todayDate, activitiesFetchModel.get(index).value, activitiesFetchModel.get(index).kind)
                            fetchDB()
                        })
                    }

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
                            width: height
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
                            font.pixelSize: Theme.fontSizeMedium;
                            font.family: Theme.fontFamily
                            anchors.bottom: valueText.bottom
                            anchors.horizontalCenter: textFirstLetter.horizontalCenter
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateTodayText
                            text: qsTr("Act. Date: ") + todayDate;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: textAltura.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: dateToPayText
                            text: qsTr("Paym. Date: ") + datePaid;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateTodayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: valueText
                            text: (options.currencyBefore ? (options.currency + " ") : "") + value.toFixed(2).replace(".",",") + (!options.currencyBefore ? (" " + options.currency) : "");
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.left: textFirstLetter.right
                            anchors.leftMargin: 40
                            color: Theme.primaryColor;
                        }
                        Text {
                            id: kindText
                            text: kind;
                            font.pixelSize: categoryText.font.pixelSize;
                            font.family: Theme.fontFamily
                            anchors.top: dateToPayText.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 30
                            color: Theme.primaryColor;
                        }

                        Component {
                            id: contextMenu
                            ContextMenu {
                                anchors.horizontalCenter: container.horizontalCenter

                                MenuItem {
                                    text: qsTr("Edit")
                                    onClicked: {
                                        editingFetchDB = true;
                                        var kindIndex;
                                        if (activitiesFetchModel.get(index).kind === appWindow.variableEng)
                                            kindIndex = 0
                                        else if (activitiesFetchModel.get(index).kind === appWindow.fixedEng)
                                            kindIndex = 1
                                        else if (activitiesFetchModel.get(index).kind === appWindow.oneTimeEng)
                                            kindIndex = 2
                                        var dialog = pageStack.push("EditDialog.qml", {"parentKind": "PAID", "nameOld": activitiesFetchModel.get(index).name, "categoryOld": activitiesFetchModel.get(index).category, "dateOld": activitiesFetchModel.get(index).datePaid, "todayDateOld": activitiesFetchModel.get(index).todayDate, "valueOld": activitiesFetchModel.get(index).value, "kindOldIndex": kindIndex})
                                        //dialog.accepted.connect( function() {fetchDB()} )
                                    }
                                }
                                MenuItem {
                                    text: qsTr("Delete")
                                    onClicked: {
                                        deleteRemorseFetch();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Button {
                text: qsTr("Fetch")
                width: 0.5 * parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked:
                {
                    fetchDB();
                }
            }
            SilicaListView {
                id: activitiesFetchListView
                height: activitiesFetchModel.count > 0 ? rootStats.height / 2  : 0;
                spacing: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
                clip: true
                model: activitiesFetchModel
                delegate: activitiesFetchDelegate
                focus: true
                Behavior on height { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 250; } }
            }
        }
    }

    function leadZero(n) {
        return (n < 10) ? ("0" + n) : n;
    }

    function getMaxOfArray(numArray) {
      return Math.max.apply(null, numArray);
    }

    function getMinOfArray(numArray) {
      return Math.min.apply(null, numArray);
    }

    function getPaid(days)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        valuesTest = []
        barGraphDays.xLabels = []
        activitiesDaysModel.clear();

        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS PAID(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, NAME TEXT NOT NULL, CATEGORY TEXT, DATE TEXT NOT NULL, TODAY_DATE TEXT NOT NULL, VALUE REAL NOT NULL, KIND TEXT NOT NULL)');

                var kindAux
                if (comboBoxKind.currentIndex !== 3)
                {
                    if(comboBoxKind.value === appWindow.variable)
                        kindAux = appWindow.variableEng
                    if(comboBoxKind.value === appWindow.fixed)
                        kindAux = appWindow.fixedEng
                    if(comboBoxKind.value === appWindow.oneTime)
                        kindAux = appWindow.oneTimeEng
                }
                else
                    kindAux = "%"

                for (var j = 0; j < days; ++j)
                {
                    var rs = tx.executeSql('SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.TODAY_DATE, PAID.VALUE, PAID.KIND FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME AND PAID.KIND LIKE "' + kindAux + '" AND PAID.DATE = "' + options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -(days - 1) + j, "yyyy/MM/dd") + '" ORDER BY PAID.DATE');
                    var total = 0
                    for (var i = 0; i < rs.rows.length; ++i)
                    {
                        var kindLanguage;
                        if (rs.rows.item(i).KIND === "Variable")
                            kindLanguage = appWindow.variable
                        if (rs.rows.item(i).KIND === "Fixed")
                            kindLanguage = appWindow.fixed
                        if (rs.rows.item(i).KIND === "One Time")
                            kindLanguage = appWindow.oneTime

                        total += rs.rows.item(i).VALUE;
                        var data = rs.rows.item(i).DATE.substring(8, 10) + "/" + rs.rows.item(i).DATE.substring(5, 8) + rs.rows.item(i).DATE.substring(0, 4)
                        var todayDate = rs.rows.item(i).TODAY_DATE.substring(8, 10) + "/" + rs.rows.item(i).TODAY_DATE.substring(5, 8) + rs.rows.item(i).TODAY_DATE.substring(0, 4)
                        activitiesDaysModel.insert(activitiesDaysModel.count, {"name":rs.rows.item(i).NAME, "category":rs.rows.item(i).CATEGORY, "datePaid":data, "todayDate":todayDate, "value":rs.rows.item(i).VALUE, "kind":kindLanguage})
                    }
                    var day = options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -(days - 1) + j, "dd")
                    barGraphDays.xLabels.push(parseInt(day));
                    valuesTest.push(total);
                }
                barGraphDays.yAxisMin = 0 //getMinOfArray(valuesTest) //Math.min(valuesTest)
                if(getMaxOfArray(valuesTest) > barGraphDays.target)
                    barGraphDays.yAxisMax = getMaxOfArray(valuesTest) //40//Math.max(valuesTest)
                else
                    barGraphDays.yAxisMax = barGraphDays.target
                barGraphDays.values = valuesTest
                if(barGraphDays.values.length > 1)
                    lastXDays.text = qsTr("Last ") + barGraphDays.values.length + qsTr(" days")
                else if(barGraphDays.values.length > 0)
                    lastXDays.text = qsTr("Today")
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

                rs = tx.executeSql('SELECT * FROM CATEGORIES ORDER BY NAME');
                for (var i = 0; i < rs.rows.length; ++i)
                {
                    categoryModel.insert(categoryModel.count, {"category":rs.rows.item(i).NAME})
                }
                timeInit.restart();
            }
        )
    }

    function fetchDB()
    {
        valuesTest = []
        activitiesFetchModel.clear();
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);


        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS PAID(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, NAME TEXT NOT NULL, CATEGORY TEXT, DATE TEXT NOT NULL, TODAY_DATE TEXT NOT NULL, VALUE REAL NOT NULL, KIND TEXT NOT NULL)');

                var dataFrom = textInputDateFrom.text.substring(6, 10) + "/" + textInputDateFrom.text.substring(3, 6) + textInputDateFrom.text.substring(0, 2)
                var dataTo = textInputDateTo.text.substring(6, 10) + "/" + textInputDateTo.text.substring(3, 6) + textInputDateTo.text.substring(0, 2)
                var rs = tx.executeSql('SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.TODAY_DATE, PAID.VALUE, PAID.KIND FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME AND PAID.NAME LIKE "%' + textInputName.text + '%" AND PAID.DATE >= "' + dataFrom + '" AND PAID.DATE <= "' + dataTo + '" ORDER BY PAID.DATE');
                for (var i = 0; i < rs.rows.length; ++i)
                {
                    var kindLanguage;
                    if (rs.rows.item(i).KIND === "Variable")
                        kindLanguage = appWindow.variable
                    if (rs.rows.item(i).KIND === "Fixed")
                        kindLanguage = appWindow.fixed
                    if (rs.rows.item(i).KIND === "One Time")
                        kindLanguage = appWindow.oneTime

                    var data = rs.rows.item(i).DATE.substring(8, 10) + "/" + rs.rows.item(i).DATE.substring(5, 8) + rs.rows.item(i).DATE.substring(0, 4);
                    var todayDate = rs.rows.item(i).TODAY_DATE.substring(8, 10) + "/" + rs.rows.item(i).TODAY_DATE.substring(5, 8) + rs.rows.item(i).TODAY_DATE.substring(0, 4)
                    activitiesFetchModel.insert(activitiesFetchModel.count, {"name":rs.rows.item(i).NAME, "category":rs.rows.item(i).CATEGORY, "datePaid":data, "todayDate":todayDate, "value":rs.rows.item(i).VALUE, "kind":kindLanguage})
                }
            }
        )
    }

    function getPaidCategory(intervalKind, interval, category)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        valuesTest = []
        barGraphCategory.xLabels = []
        activitiesCategoriesModel.clear();

        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS PAID(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, NAME TEXT NOT NULL, CATEGORY TEXT, DATE TEXT NOT NULL, TODAY_DATE TEXT NOT NULL, VALUE REAL NOT NULL, KIND TEXT NOT NULL)');

                for (var j = 0; j < interval; ++j)
                {
                    var rs;
                    if(intervalKind === "Days")
                        rs = tx.executeSql('SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.TODAY_DATE, PAID.VALUE, PAID.KIND FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME AND PAID.CATEGORY = "' + category + '"AND PAID.DATE = "' + options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -(interval - 1) + j, "yyyy/MM/dd") + '" ORDER BY PAID.DATE');
                    else if (intervalKind === "Months")
                        rs = tx.executeSql('SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.TODAY_DATE, PAID.VALUE, PAID.KIND FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME AND PAID.CATEGORY = "' + category + '" AND PAID.DATE LIKE "' + options.returnDateMonths(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -(interval - 1) + j, "yyyy/MM/__") + '" ORDER BY PAID.DATE');
                    var total = 0
                    for (var i = 0; i < rs.rows.length; ++i)
                    {
                        var kindLanguage;
                        if (rs.rows.item(i).KIND === "Variable")
                            kindLanguage = appWindow.variable
                        if (rs.rows.item(i).KIND === "Fixed")
                            kindLanguage = appWindow.fixed
                        if (rs.rows.item(i).KIND === "One Time")
                            kindLanguage = appWindow.oneTime

                        total += rs.rows.item(i).VALUE;
                        var data = rs.rows.item(i).DATE.substring(8, 10) + "/" + rs.rows.item(i).DATE.substring(5, 8) + rs.rows.item(i).DATE.substring(0, 4)
                        var todayDate = rs.rows.item(i).TODAY_DATE.substring(8, 10) + "/" + rs.rows.item(i).TODAY_DATE.substring(5, 8) + rs.rows.item(i).TODAY_DATE.substring(0, 4)
                        activitiesCategoriesModel.insert(activitiesCategoriesModel.count, {"name":rs.rows.item(i).NAME, "category":rs.rows.item(i).CATEGORY, "datePaid":data, "todayDate":todayDate, "value":rs.rows.item(i).VALUE, "kind":kindLanguage})
                    }
                    var xlab;
                    if (intervalKind === "Days")
                        xlab = options.returnDate(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -(interval - 1) + j, "dd")
                    else if (intervalKind === "Months")
                        xlab = options.returnDateMonths(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -(interval - 1) + j, "MM")

                    barGraphCategory.xLabels.push(parseInt(xlab));
                    valuesTest.push(total);
                }
                barGraphCategory.yAxisMin = 0 //getMinOfArray(valuesTest) //Math.min(valuesTest)
                if(getMaxOfArray(valuesTest) > barGraphCategory.target)
                    barGraphCategory.yAxisMax = getMaxOfArray(valuesTest) //40//Math.max(valuesTest)
                else
                    barGraphCategory.yAxisMax = barGraphCategory.target
                barGraphCategory.values = valuesTest
                lastXInterval.text = qsTr("Last ") + barGraphCategory.values.length + " " + (options.categoryPeriod === "Months" ? appWindow.months : appWindow.days)
            }
        )
    }

    function getPaidMonths(months)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        valuesTest = []
        barGraphMonths.xLabels = []
        activitiesMonthsModel.clear();

        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS PAID(ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, NAME TEXT NOT NULL, CATEGORY TEXT, DATE TEXT NOT NULL, TODAY_DATE TEXT NOT NULL, VALUE REAL NOT NULL, KIND TEXT NOT NULL)');

                var kindAux
                if (comboBoxKind.currentIndex !== 3)
                {
                    if(comboBoxKind.value === appWindow.variable)
                        kindAux = appWindow.variableEng
                    if(comboBoxKind.value === appWindow.fixed)
                        kindAux = appWindow.fixedEng
                    if(comboBoxKind.value === appWindow.oneTime)
                        kindAux = appWindow.oneTimeEng
                }
                else
                    kindAux = "%"

                for (var j = 0; j < months; ++j)
                {
                    var rs = tx.executeSql('SELECT PAID.NAME, PAID.CATEGORY, PAID.DATE, PAID.TODAY_DATE, PAID.VALUE, PAID.KIND FROM PAID INNER JOIN CATEGORIES WHERE PAID.CATEGORY = CATEGORIES.NAME AND PAID.KIND LIKE "' + kindAux + '" AND PAID.DATE LIKE "' + options.returnDateMonths(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -(months - 1) + j, "yyyy/MM/__") + '" ORDER BY PAID.DATE');
                    var total = 0
                    for (var i = 0; i < rs.rows.length; ++i)
                    {
                        var kindLanguage;
                        if (rs.rows.item(i).KIND === "Variable")
                            kindLanguage = appWindow.variable
                        if (rs.rows.item(i).KIND === "Fixed")
                            kindLanguage = appWindow.fixed
                        if (rs.rows.item(i).KIND === "One Time")
                            kindLanguage = appWindow.oneTime

                        total += rs.rows.item(i).VALUE;
                        var data = rs.rows.item(i).DATE.substring(8, 10) + "/" + rs.rows.item(i).DATE.substring(5, 8) + rs.rows.item(i).DATE.substring(0, 4)
                        var todayDate = rs.rows.item(i).TODAY_DATE.substring(8, 10) + "/" + rs.rows.item(i).TODAY_DATE.substring(5, 8) + rs.rows.item(i).TODAY_DATE.substring(0, 4)
                        activitiesMonthsModel.insert(activitiesMonthsModel.count, {"name":rs.rows.item(i).NAME, "category":rs.rows.item(i).CATEGORY, "datePaid":data, "todayDate":todayDate, "value":rs.rows.item(i).VALUE, "kind":kindLanguage})
                    }
                    var month = options.returnDateMonths(Qt.formatDateTime(new Date(), "yyyy/MM/dd"), -(months - 1) + j, "MM")
                    barGraphMonths.xLabels.push(parseInt(month));
                    valuesTest.push(total);
                }
                barGraphMonths.yAxisMin = 0 //getMinOfArray(valuesTest) //Math.min(valuesTest)
                if(getMaxOfArray(valuesTest) > barGraphMonths.target)
                    barGraphMonths.yAxisMax = getMaxOfArray(valuesTest) //40//Math.max(valuesTest)
                else
                    barGraphMonths.yAxisMax = barGraphMonths.target
                barGraphMonths.values = valuesTest
                if(barGraphMonths.values.length > 1)
                    lastXMonths.text = qsTr("Last ") + barGraphMonths.values.length + qsTr(" months")
                else if(barGraphMonths.values.length > 0)
                    lastXMonths.text = qsTr("This month")
            }
        )
    }
}
