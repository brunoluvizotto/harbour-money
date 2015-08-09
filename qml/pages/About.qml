import QtQuick 2.0
import Sailfish.Silica 1.0
import "../pages"

Page {
    id: about_page
    anchors.centerIn: parent

    allowedOrientations: Orientation.Portrait + Orientation.Landscape + Orientation.LandscapeInverted

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: about_column.height + about_translators_column.height
        contentWidth: parent.width
        Column {
            id: about_column
            spacing: Theme.paddingMedium
            width: parent.width
            anchors.top: parent.top
            PageHeader {
                title: qsTr("About")
            }
            Label {
                text: "Money"
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label {
                text: "0.4.1"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label {
                text: qsTr("Author: ") + "Bruno Luvizotto"
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Row {
                spacing: Theme.paddingSmall
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    height: email_id.height
                    width: height
                    source: "../Imagens/gmail-icon-logo.png"
                }
                Label {
                    id: email_id
                    text: "brunoluvizotto@gmail.com"
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    //anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = Theme.highlightColor
                        onReleased: parent.color = Theme.primaryColor
                        onClicked: Qt.openUrlExternally("mailto:brunoluvizotto@gmail.com" +
                                                        "?subject=Money App and other things :)")
                    }
                }
            }
            Row {
                spacing: Theme.paddingSmall
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    height: email_id.height
                    width: height
                    source: "../Imagens/Twitter-icon-logo.png"
                }
                Label {
                    text: "www.twitter.com/brunoluvizotto"
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    //anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = Theme.highlightColor
                        onReleased: parent.color = Theme.primaryColor
                        onClicked: Qt.openUrlExternally("http://www.twitter.com/brunoluvizotto")
                    }
                }
            }
            Row {
                spacing: Theme.paddingSmall
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    height: email_id.height
                    width: height
                    source: "../Imagens/linkedin-icon-logo.png"
                }
                Label {
                    text: "Bruno Valdrighi Luvizotto"
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    //anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.color = Theme.highlightColor
                        onReleased: parent.color = Theme.primaryColor
                        onClicked: Qt.openUrlExternally("http://br.linkedin.com/pub/bruno-valdrighi-luvizotto/27/8ba/4a6/")
                    }
                }
            }
            Image {
                width: parent.width / 4
                height: width / 3
                fillMode: Image.PreserveAspectFit
                source: "../Imagens/btn_donate_LG.gif"
                anchors.horizontalCenter: parent.horizontalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=R7ZWGUQTHQRJ4")
                }
            }
        }
        Column
        {
            id: about_translators_column
            spacing: Theme.paddingMedium
            width: parent.width
            anchors.top: about_column.bottom
            anchors.topMargin: 40
            Separator {
                width: parent.width
                color: Theme.secondaryColor
            }
            Label{
                text: qsTr("Special thanks to the translators:")
                horizontalAlignment: Text.AlignHCenter
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label{
                text: "Dutch"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label{
                text: "Nathan Follens"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label{
                text: "German"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label{
                text: "Patrick Meier"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label{
                text: "Norwegian (Bokmål)"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label{
                text: "Nathan Follens"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
