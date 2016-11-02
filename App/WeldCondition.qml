import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as QuickControls
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2

Item{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "WeldCondition"
    anchors.fill: parent

    property var weldWireLengthModel:     ["10mm","15mm","20mm","25mm"];
    property var swingWayModel:                ["无","左方","右方","左右"];
    property var weldWireModel:                 ["实芯碳钢","药芯碳钢"];
    property var robotLayoutModel:            ["坡口侧","非坡口侧"];
    property var weldWireDiameterModel: ["1.2mm","1.6mm"];
    property var weldGasModel:                   ["CO2","MAG"];
    property var returnWayModel:               ["单向","往返"];
    property var weldPowerModel:              ["关闭","打开"];
    property var weldTrackModel:                ["关闭","打开"];

    property bool type:AppConfig.currentUserType==="超级用户"?true:false

    property var condition: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    property var oldCondition: condition

    property int selectedIndex:0

    property var listName: ["焊丝伸出长度:","头部摇动方式:","焊丝种类:","机头放置侧:","焊丝直径:","保护气体:","焊接往返动作:","焊接脉冲状态:","电弧跟踪:","预期余高:","溶敷系数:","焊接电流偏置:","焊接电压偏置:","提前送气时间:","滞后送气时间","起弧停留时间:","收弧停留时间","起弧电流:","起弧电压:","收弧电流:","收弧电压:"]

    property var listValueName: [weldWireLengthModel,swingWayModel,weldWireModel,robotLayoutModel,weldWireDiameterModel,weldGasModel,returnWayModel,weldPowerModel,weldTrackModel]

    property var listDescription: ["设定焊丝端部到导电嘴的长度。",
        "设定在焊接的起始、端部头部是否摆动。",
        "设定焊丝种类实芯碳钢或药芯碳钢。",
        "设定机头相对于坡口的放置位置。",
        "设定焊丝的直径。",
        "设定焊接过程中使用保护气体。",
        "设定焊接往返动作方向为往返方向或单向。",
        "设定电源特性，直流或脉冲。",
        "设定电弧跟踪是否开启。",
        "设定焊接预期板面焊道堆起高度。",
        "设定焊接过程中溶敷系数的大小，以方便推算更合适的焊接规范。",
        "焊接条件所设定的电流和实际电流的微调整。",
        "焊接条件所设定的电压和实际电压的微调整。",
        "设定焊接提前送气时间。",
        "设定焊接滞后送气时间。",
        "设定焊接起弧停留时间。",
        "设定焊接收弧停留时间。",
        "设定焊接起弧电流。",
        "设定焊接起弧电压。",
        "设定焊接收弧电流。",
        "设定焊接收弧电压。"]

    property var valueType: ["mm","%","A","V","S","S","S","S","A","V","A","V"]

    //脉冲有无
    property int oldPulse:0
    //焊丝种类
    property int oldWireType:0
    //焊丝直径
    property int oldWireD:0
    //气体
    property int oldGas:0

    signal changeSelectedIndex(int index)
    signal changeValue(int index)
    signal changeGroupCurrent(int index)
    signal changeValueText(var value)

    signal doWork(int index,bool flag)

    signal changeGas(int value)
    signal changeWireD(int value)
    signal changeWireType(int value)
    signal changePulse(int value)

    onChangeSelectedIndex: {
        selectedIndex=index;
    }
    onChangeValue: {
          root.oldCondition[selectedIndex]=root.condition[selectedIndex]
        root.condition[selectedIndex]=index;
        doWork(selectedIndex,true);
    }
    onChangeGroupCurrent: {
        doWork(selectedIndex,true);
    }
    onChangeValueText: {
        doWork(selectedIndex,true);
    }
    onDoWork: {
        var frame=new Array();
        frame.push("W");
        var num=Number(root.condition[index]);
        switch(index){
            //干伸长
        case 0: frame.push("120");frame.push("1");frame.push(num ===0?"1":num===1?"3":num===2?"4":"6");break;
            //头部摆动方式
        case 1:frame.push("121");frame.push("1");frame.push(String(num));break;
            // 焊丝种类
        case 2:frame.push("126");frame.push("1");frame.push(num ===0?"0":"4");changeWireType(num===0?0:4);WeldMath.setWireType(num===0?0:4);break;
            //机头放置侧
        case 3:frame.push("122");frame.push("1");frame.push(String(num));break;
            //焊丝直径
        case 4:frame.push("123");frame.push("1");frame.push(num ===0?"4":"6");changeWireD(num===0?4:6);WeldMath.setWireD(num===0?4:6);break;
            //保护气体
        case 5:frame.push("124");frame.push("1");frame.push(String(num ));changeGas(num);WeldMath.setGas(num);break;;break;
            //往返动作
        case 6:frame.push("125");frame.push("1");frame.push(String(num ));break;
            //电源特性
        case 7:frame.push("119");frame.push("1");frame.push(String(num ));changePulse(num);WeldMath.setPulse(num);break;
            //电弧跟踪
        case 8:frame.push("127");frame.push("1");frame.push(String(num));break;
            //预期余高
        case 9:WeldMath.setReinforcement(num);break;
            //溶敷系数
        case 10:WeldMath.setMeltingCoefficient(num);break;
            //焊接电流偏置
        case 11:frame.push("128");frame.push("1");frame.push(String(num));break;
            //焊接电压偏置
        case 12:frame.push("129");frame.push("1");frame.push(String(num*10));break;
            //提前送气时间
        case 13:frame.push("132");frame.push("1");frame.push(String(num*10));break;
            //滞后送气时间
        case 14:frame.push("133");frame.push("1");frame.push(String(num*10));break;
            //起弧停留时间
        case 15:frame.push("134");frame.push("1");frame.push(String(num*10));break;
            //收弧停留时间
        case 16:frame.push("135");frame.push("1");frame.push(String(num*10));break;
            //起弧电流
        case 17:frame.push("136");frame.push("1");frame.push(String(num));break;
            //起弧电压
        case 18:frame.push("137");frame.push("1");frame.push(String(num*10));break;
            //收弧电流
        case 19:frame.push("138");frame.push("1");frame.push(String(num));break;
            //收弧电压
        case 20:frame.push("139");frame.push("1");frame.push(String(num*10));break;
        default:frame.length=0;break;
        }
        if(frame.length===4){
            ERModbus.setmodbusFrame(frame)
        }
        if(flag){
            //存储数据
            Material.UserData.setValueFromFuncOfTable(root.objectName,index,num)
        }
        console.log(frame)
        //清空
        frame.length=0;
    }
    Timer{
        id:keyTime;repeat: false;interval: 300;running: false;
        onTriggered:{
            //  按键长按触发
        }
    }
    Keys.onPressed: {
        var temp;
        var num=Number(root.condition[selectedIndex]);
        if(event.key===Qt.Key_Down){
            if(selectedIndex<listName.length){
                selectedIndex++;
            }
        }else if(event.key===Qt.Key_Up){
            if(selectedIndex>0){
                selectedIndex--;
            }
        }else if(event.key===Qt.Key_Left){
            if((num>0)&&(selectedIndex<listValueName.length)){
                   root.oldCondition[selectedIndex]=root.condition[selectedIndex]
                num-=1;

                root.condition[selectedIndex]=num;
                changeGroupCurrent(num);
            }
        }else if(event.key===Qt.Key_Right){
            if((num<(listValueName[selectedIndex].length-1))&&(selectedIndex<listValueName.length)){
                  root.oldCondition[selectedIndex]=root.condition[selectedIndex]
                num+=1;

                root.condition[selectedIndex]=num;
                changeGroupCurrent(num);
            }
        }else if(event.key===Qt.Key_VolumeDown){
            temp=selectedIndex-listValueName.length;
            switch(temp){
                //余高层
            case 0:num-=1; if(num<-3)num=-3;break;
                //溶敷系数
            case 1:num-=1; if(num<50)num=50;break;
                //电流偏置
            case 2:num-=1; if(num<-100)num=-100;break;
                //电压偏置
            case 3:num-=0.1;num=num.toFixed(1); if(num<-10)num=-10;break;
                //提前送气时间
            case 4:
                //滞后送气时间
            case 5:
                //起弧停留时间
            case 6:
                //收弧停留时间
            case 7:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
                //起弧电流
            case 8:num-=1; if(num<0)num=0;break;
                //起弧电压
            case 9:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
                //收弧电流
            case 10:num-=1; if(num<0)num=0;break;
                //收弧电压
            case 11:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
            }
            if(temp>=0){
                root.condition[selectedIndex]=num;
                changeValueText(num);
            }
        }else if(event.key===Qt.Key_VolumeUp){
            temp=selectedIndex-listValueName.length;
            switch(temp){
                //余高层
            case 0:num+=1; if(num>3)num=3;break;
                //溶敷系数
            case 1:num+=1; if(num>150)num=150;break;
                //电流偏置
            case 2:num+=1; if(num>100)num=100;break;
                //电压偏置
            case 3:num+=0.1; num=num.toFixed(1);if(num>10)num=10;break;
                //提前送气时间
            case 4:
                //滞后送气时间
            case 5:
                //起弧停留时间
            case 6:
                //收弧停留时间
            case 7:num+=0.1; num=num.toFixed(1);if(num>5)num=5;break;
                //起弧电流
            case 8:num+=1; if(num>300)num=300;break;
                //起弧电压
            case 9:num+=0.1; num=num.toFixed(1);if(num>30)num=30;break;
                //收弧电流
            case 10:num+=1; if(num>300)num=300;break;
                //收弧电压
            case 11:num+=0.1;num=num.toFixed(1); if(num>30)num=30;break;
            }
            if(temp>=0){
                root.condition[selectedIndex]=num;
                changeValueText(num);
            }
        }
        event.accpet=true;
    }
    //滚屏
    onSelectedIndexChanged: {
        switch(selectedIndex){
        case 0:flickable.contentY=0;break;
        case 6:flickable.contentY=0;break;
        case 7:flickable.contentY=Material.Units.dp(44)*7;break;
        case 13:flickable.contentY=Material.Units.dp(44)*7;break;
        case 14:flickable.contentY=Material.Units.dp(44)*14;break;
        case 20:flickable.contentY=Material.Units.dp(44)*14;break;
        case 21:flickable.contentY=Material.Units.dp(44)*21;break;
        }
    }
    Material.Card{
        anchors{ left:parent.left;right:parent.right;top:parent.top;bottom: descriptionCard.top;margins:Material.Units.dp(12)}
        elevation: 2
        Material.Label{
            id:title
            anchors.left: parent.left
            anchors.leftMargin: Material.Units.dp(24)
            height: Material.Units.dp(64)
            verticalAlignment:Text.AlignVCenter
            text:qsTr("焊接条件");
            style:"subheading"
            color: Material.Theme.light.shade(0.87)
        }
        Flickable{
            id:flickable
            anchors{top:title.bottom;left:parent.left;right:parent.right;bottom:parent.bottom}
            interactive: false
            clip: true
            contentHeight: column.height
            Behavior on contentY{NumberAnimation { duration: 200 }}
            Column{
                id:column
                anchors{ left:parent.left;right:parent.right;top:parent.top}
                Repeater{

                    model: listValueName.length
                    delegate:ListItem.Subtitled{
                        id:sub
                        property int subIndex:index
                        text:listName[index]
                        leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                        Behavior on leftMargin{NumberAnimation { duration: 200 }}
                        height: Material.Units.dp(44)
                        selected: selectedIndex===index
                        onPressed: changeSelectedIndex(index)
                        Connections{
                            target: root
                            onChangeGroupCurrent:{
                                if(sub.selected)
                                    group.current=re.itemAt(index);
                            }
                        }
                        secondaryItem:Row{
                            anchors.verticalCenter: parent.verticalCenter
                            QuickControls.ExclusiveGroup {id:group }
                            Repeater{
                                id:re
                                model:sub.subIndex<listValueName.length?listValueName[sub.subIndex]:listName.length
                                delegate:Material.RadioButton{
                                    text:modelData
                                    checked:index===root.condition[sub.subIndex]
                                    onClicked:{ changeSelectedIndex(sub.subIndex);changeValue(index)}
                                    exclusiveGroup: group
                                }
                            }
                        }
                    }
                }
                Repeater{
                    model:listName.length-listValueName.length
                    delegate:ListItem.Subtitled{
                        id:downSub
                        property int num: listValueName.length+index
                        text:listName[num]
                        leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                        Behavior on leftMargin{NumberAnimation { duration: 200 }}
                        height: Material.Units.dp(44)
                        selected: selectedIndex===num
                        onPressed: changeSelectedIndex(num)
                        Connections{
                            target: root
                            onChangeValueText:{
                                if(downSub.selected)
                                    valueLabel.text=value;
                            }
                        }
                        secondaryItem:Row{
                            spacing: Material.Units.dp(16)
                            anchors.verticalCenter: parent.verticalCenter
                            Material.Label{id:valueLabel;text: root.condition[downSub.num];}
                            Material.Label{ text:valueType[index] }
                        }
                    }
                }
            }
        }
        Material.Scrollbar {id:scrollbar;flickableItem:flickable ;
            onMovingChanged: {scrollbar.hide.stop();scrollbar.show.start();}
            Component.onCompleted:{scrollbar.hide.stop();scrollbar.show.start();}
        }
    }
    Material.Card{
        id:descriptionCard
        anchors{
            left:parent.left
            right:parent.right
            bottom: parent.bottom
            margins: Material.Units.dp(12)
        }
        elevation: 2
        height:Material.Units.dp(110);
        Column{
            anchors.fill: parent
            Material.Label{
                id:descriptiontitle
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(24)
                height: Material.Units.dp(64)
                verticalAlignment:Text.AlignVCenter
                text:qsTr("描述信息");
                style:"subheading"
                color: Material.Theme.light.shade(0.87)
            }
            Material.Label{
                id:descriptionlabel
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(48)
                text:selectedIndex<listDescription.length?listDescription[selectedIndex]:""
            }
        }
    }
    Component.onCompleted: {
        oldCondition=condition=Material.UserData.getValueFromFuncOfTable("WeldCondition","","");
        for(var i=0;i<listName.length;i++){
            doWork(i,false);
        }
    }
}
