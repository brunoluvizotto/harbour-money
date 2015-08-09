import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../"

Dialog {
    id: root

    allowedOrientations: Orientation.Portrait + Orientation.Landscape + Orientation.LandscapeInverted
    canAccept: textInputNewCategory.text.length

    property string oldCategory: ""

    onAccepted:
    {
        editCategoriesTable(textInputNewCategory.text, oldCategory)
        editCategory(textInputNewCategory.text, oldCategory, "PAID")
        editCategory(textInputNewCategory.text, oldCategory, "TO_PAY")
    }

    function editCategoriesTable(newCategoryName, oldCategoryName)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                tx.executeSql('UPDATE CATEGORIES SET NAME = "' + newCategoryName + '" WHERE NAME = "' + oldCategoryName + '"')
            }
        )
    }

    function editCategory(newCategoryName, oldCategoryName, tableName)
    {
        var db = LocalStorage.openDatabaseSync("ExpensesMan DB", "1.0", "Database for the ExpensesMan app!", 1000000);

        db.transaction(
            function(tx) {
                tx.executeSql('UPDATE ' + tableName + ' SET CATEGORY = "' + newCategoryName + '" WHERE CATEGORY = "' + oldCategoryName + '"')
            }
        )
    }

    SilicaFlickable {
        id: header
        anchors.fill: parent
        contentHeight: column.height
        clip: true

        Column {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.paddingLarge

            PageHeader {
                id: headerTitle
                title: qsTr("Edit Category:") + " " + oldCategory
            }

            TextField {
                id: textInputNewCategory
                text: ""
                width: 0.8 * parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: TextInput.AlignHCenter
                maximumLength: 14
                focus: true
                font.pixelSize: Theme.fontSizeMedium;

                placeholderText: qsTr("New category name")
                label: placeholderText

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: root.accept()
            }
        }
    }

}
