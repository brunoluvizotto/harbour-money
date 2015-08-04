import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: root
    width: 200
    height: 100
    color: "transparent"

    property var values: []
    property var xLabels: []
    property int repeaterModel: values.length
    property int repeaterSpacing: (graph.width / (root.repeaterModel + 1)) / root.repeaterModel > 0 ? (graph.width / (root.repeaterModel + 1)) / root.repeaterModel : 0
    property real xAxisMin: 0
    property real xAxisMax: 100
    property real yAxisMin: 0
    property real yAxisMax: 100
    property string yLabel: ""
    property real target: 0

    onValuesChanged:
    {
        update()
    }

    Rectangle {
        id: graph
        anchors {
            fill: root
            topMargin: Theme.paddingLarge
            bottomMargin: Theme.paddingLarge
            leftMargin: 2 * Theme.paddingLarge
            rightMargin: 3 * Theme.paddingLarge
        }
        color: "transparent"

        Row {
            spacing: root.repeaterSpacing
            anchors.left: leftLine.right
            anchors.leftMargin: spacing / 2
            anchors.bottom: parent.bottom
            Repeater {
                model: root.repeaterModel
                anchors.bottom: parent.bottom
                Column {
                    width: barRectangle.width
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -xLab.height
                    Label {
                        id: valueLabel
                        text: values[index].toFixed(0)
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 0.9 * Theme.fontSizeTiny;
                    }
                    Rectangle {
                        id: barRectangle
                        height: (graph.height * (values[index] - yAxisMin)) / (yAxisMax - yAxisMin) > 0 ? (graph.height * (values[index] - yAxisMin)) / (yAxisMax - yAxisMin) : 1
                        width: graph.width / (root.repeaterModel + 1) //(parent.parent.width / parent.model) - (parent.parent.spacing * parent.model)
                        color: Theme.highlightColor
                        Behavior on height { PropertyAnimation { easing.type: Easing.InOutCubic; duration: 1000; } }
                    }
                    Label {
                        id: xLab
                        text: xLabels[index] //xLabels.length > 0 ? xLabels[index] : " "
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 0.9 * Theme.fontSizeTiny;
                    }
                }
            }
        }

        Label {
            id: yLabelGraph
            text: yLabel
            rotation: -90
            anchors.right: leftLine.left
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeTiny;
        }
        Rectangle {
            id: targetLine
            visible: target > 0
            width: graph.width
            height: 2
            anchors.horizontalCenter: parent.horizontalCenter
            y: bottomLine.y - (graph.height * (target - yAxisMin)) / (yAxisMax - yAxisMin)
            color: Theme.secondaryColor
        }
        Label {
            id: targetLabel
            visible: target > 0
            text: target.toFixed(0)
            anchors.left: targetLine.right
            anchors.leftMargin: Theme.paddingSmall
            anchors.verticalCenter: targetLine.verticalCenter
            font.pixelSize: Theme.fontSizeTiny;
            color: Theme.secondaryColor
        }

        Rectangle {
            id: bottomLine
            width: graph.width
            height: 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            color: Theme.primaryColor
        }
        Rectangle {
            id: leftLine
            width: 2
            height: graph.height
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.primaryColor
        }
    }
}
