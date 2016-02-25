import QtQuick 2.2
import Material 0.1 as Material
import Material.Extras 0.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.2

TableViewStyle{
    //corner commpent 指 两个横纵滚动条之间的 部件
    corner: Item{visible: false}
    //decrementControl 指滚动条 减 箭头 部件
    decrementControl:Rectangle{visible: false}
    //handle 滚动条滑块儿
    handle:Rectangle{
        property bool sticky: false
        property bool hovered: __activeControl !== "none"
        implicitWidth: !styleData.horizontal ? 5:Math.round(TextSingleton.implicitHeight) + 1
        implicitHeight: styleData.horizontal ? 5:Math.round(TextSingleton.implicitHeight) + 1
        width: !styleData.horizontal && transientScrollBars ? sticky ? 10 : 5 : parent.width-10
        height: styleData.horizontal && transientScrollBars ? sticky ? 10 : 5 : parent.height-4
        color: Material.Palette.colors["grey"]["400"]
        anchors.centerIn: parent
        radius: styleData.horizontal ? width/2 : height/2
        onHoveredChanged: {if (hovered) sticky = true;}
        onVisibleChanged:{ if (!visible) sticky = false;}
    }
    //incrementControl 指滚动条 加 箭头 部件
    incrementControl:Rectangle{visible: false}
    //minimumHandleLength 滚动条滑块儿
    minimumHandleLength:30
    //scrollBarBackground 滚动条滑块儿外的颜色
    scrollBarBackground:Rectangle{
        property bool sticky: false
        property bool hovered: styleData.hovered
        implicitWidth: !styleData.horizontal ? 5:Math.round(TextSingleton.implicitHeight) + 1
        implicitHeight: styleData.horizontal ? 5:Math.round(TextSingleton.implicitHeight) + 1
        clip: true
        opacity: transientScrollBars ? 0.0 : 1.0
        visible: !Settings.hasTouchScreen && (!transientScrollBars || sticky)
        radius: styleData.horizontal ? width/2 : height/2
        onHoveredChanged: if (hovered) sticky = true
        onVisibleChanged: if (!visible) sticky = false
    }
    //transientScrollBars 滚动条一直存在还是短暂存在
    transientScrollBars:true
    //frame 滚动条外围组件
    frame:Item{visible: false}
    //以上是SCROLLBAR 外观设置

    //以下是TableView设置
    headerDelegate:Rectangle{
        height:Material.Units.dp(56);
        Material.Label{
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 24
            text:styleData.value
            style:"menu"
            color:Material.Theme.light.shade(0.54)
        }
        Material.ThinDivider{anchors.bottom: parent.bottom ;color:Material.Palette.colors["grey"]["500"];height:1.5}
    }
    itemDelegate: Item{
        anchors.fill: parent
        Material.Label{
            anchors.verticalCenter: parent.verticalCenter
            text:styleData.value
            style:"body1"
            anchors.left:parent.left
            anchors.leftMargin: !isNaN(Number(styleData.value)) ? parent.width-width-24 : 24
            color: Material.Theme.light.shade(0.87)
        }
    }
    rowDelegate: Rectangle{
        height: Material.Units.dp(48);
        property color selectedColor: control.activeFocus ? Material.Palette.colors["grey"]["300"] : Material.Palette.colors["grey"]["200"] ;
        color: styleData.selected ? selectedColor : "white"
        Material.ThinDivider{anchors.bottom: parent.bottom}
    }
}
