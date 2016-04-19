import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0
import QtQuick.Controls 1.4
import WeldSys.SysInfor 1.0

/*应用程序窗口*/
Material.ApplicationWindow{
    id: app;title: "app";visible: true
    /*主题默认颜色*/
    theme { primaryColor: AppConfig.themePrimaryColor;accentColor: AppConfig.themeAccentColor;backgroundColor:AppConfig.themeBackgroundColor
        tabHighlightColor: "#FFFFFF"  }
    property var grooveStyleName: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),
        qsTr("立焊单边V型坡口T接头"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接"),
        qsTr("水平角焊")  ]
    property var preset:["GrooveCondition","TeachCondition","WeldCondition","GrooveCheck"]
    property var presetName: ["坡口条件","示教条件","焊接条件","坡口参数"]
    property var presetIcon: ["awesome/road","action/android","user/MAG","awesome/road"]
    property var analyse: ["WeldAnalyse","WeldLine"]
    property var analyseName:["焊接参数","焊接曲线"]
    property var analyseIcon: ["awesome/line_chart","awesome/line_chart"]
    property var infor: ["SystemInfor"]
    property var inforName:["系统信息"]
    property var inforIcon: ["awesome/windows"]
    property var sections: [preset,analyse, infor]
    property var sectionsName:[presetName,analyseName,inforName]
    property var sectionsIcon:[presetIcon,analyseIcon,inforIcon]
    property var sectionTitles: ["预置条件", "焊接分析", "系统信息"]
    property var tabiconname: ["action/settings_input_composite","awesome/line_chart","awesome/windows"]
    property int  page0SelectedIndex:0
    property int  page1SelectedIndex:0
    property int  page2SelectedIndex:0
    /*当前本地化语言*/
    property string local: "zh_CN"
    /*当前坡口形状*/
    property int groove:AppConfig.currentGroove
    /*Modbus重载*/
    property bool modbusExist:true;
    /*系统信息采集标志*/
    property bool sysInforFlag: true;
    /*系统状态*/
    property string sysStatus:"0"
    /*上一次froceitem*/
    property Item lastFocusedItem:null
    /*错误*/
    property var promise

    /*排道参数list*/
    ListModel{
        id:weldDataList
        ListElement{
            ID:"1"
            C1:"1/1"
            C2:"300"
            C3:"30.8"
            C4:"3"
            C5:"160"
            C6:"43"
            C7:"0"
            C8:"3"
            C9:"连续"
        }
        ListElement{
            ID:"2"
            C1:"2/1"
            C2:"310"
            C3:"31.8"
            C4:"5"
            C5:"100"
            C6:"29"
            C7:"0"
            C8:"3"
            C9:"停止"
        }
        ListElement{
            ID:"3"
            C1:"3/1"
            C2:"310"
            C3:"31.8"
            C4:"10"
            C5:"50"
            C6:"20"
            C7:"0"
            C8:"3"
            C9:"连续"
        }
        ListElement{
            ID:"4"
            C1:"4/1"
            C2:"220"
            C3:"22.2"
            C4:"6"
            C5:"80"
            C6:"20"
            C7:"0"
            C8:"3"
            C9:"连续"
        }
        ListElement{
            ID:"5"
            C1:"4/2"
            C2:"220"
            C3:"22.2"
            C4:"6"
            C5:"80"
            C6:"20"
            C7:"0"
            C8:"3"
            C9:"停止"
        }
        ListElement{
            ID:""
            C1:""
            C2:""
            C3:""
            C4:""
            C5:""
            C6:""
            C7:""
            C8:""
            C9:""
        }
    }

    /*坡口检测参数list*/
    ListModel{id:grooveStyleList
    ListElement{ID:"1";C1:"1"; C2:"2";C3:"3";C4:"4";C5:"5";C6:"6";}}
    /*更新时间定时器*/
    Timer{ interval: 500; running: true; repeat: true;
        onTriggered:{
            datetime.name= new Date().toLocaleDateString(Qt.locale(app.local),"MMMdd ddd ")+new Date().toLocaleTimeString(Qt.locale(app.local),"h:mm");
        }
    }

//    Timer{
//        interval: 4000;running: true;repeat: true;
//        onTriggered: sysStatus==="0"?sysStatus="1":sysStatus==="1"?sysStatus="2":sysStatus==="2"?sysStatus="3":sysStatus==="3"?sysStatus="4":sysStatus==="4"?sysStatus="5":sysStatus==="5"?sysStatus="6":sysStatus="0";
//    }

    /*握手协议 第一个为系统状态 第二个为要读取地址 第三个为读取个数*/
    Timer{id:modbusTimer;interval: 100; running: modbusExist; repeat: true;
        onTriggered: {ERModbus.setmodbusFrame(["R","0","3"]);}
    }
    /*初始化Tabpage*/
    initialPage: Material.TabbedPage {
        id: page
        /*标题*/
        title:qsTr("便携式MAG焊接机器人系统")
        /*最大action显示数量*/
        actionBar.maxActionCount: 5
        /*actions列表*/
        actions: [
            /*危险报警action*/
            Material.Action {iconName: "alert/warning";
                name: qsTr("警告");
                //onTriggered: demo.showError("Something went wrong", "Do you want to retry?", "Close", true)
            },
            /*背光控制插件action*/
            Material.Action{name: qsTr("背光"); iconName:"device/brightness_medium";
                onTriggered:backlight.show();
            },
            /*系统选择颜色action*/
            Material.Action {iconName: "image/color_lens";
                name: qsTr("色彩") ;
                onTriggered: colorPicker.show();
            },
            /*时间action*/
            Material.Action{name: qsTr("时间"); id:datetime;
                onTriggered:datePickerDialog.show();
            },
            /*账户*/
            Material.Action {id:accountname;iconName: "awesome/user";
                onTriggered:changeuser.show();text:AppConfig.currentUserName;
            },
            /*语言*/
            Material.Action {iconName: "action/language";name: qsTr("语言");
                onTriggered: languagePicker.show();
            },
            /*系统电源*/
            Material.Action {iconName: "awesome/power_off";name: qsTr("关机")
                onTriggered: {app.modbusExist=false;app.sysInforFlag=false;Qt.quit();}
            }
        ]
        backAction: navigationDrawer.action
        actionBar.tabBar.leftKeyline: 0;
        actionBar.tabBar.isLargeDevice: false
        actionBar.tabBar.fullWidth:false
        Material.NavigationDrawer{
            id:navigationDrawer
            enabled: true
            clip: true
            Material.Card{
                id:header
                anchors.top:parent.top//tableview.bottom
                anchors.left: parent.left
                width: parent.width
                height:Material.Units.dp(64);
                Row{
                    anchors.left: parent.left
                    anchors.leftMargin: Material.Units.dp(24)
                    height: parent.height
                    spacing: Material.Units.dp(16)
                    Material.Icon{
                        size:Material.Units.dp(27)
                        anchors.verticalCenter: parent.verticalCenter
                        name: tabiconname[page.selectedTab]
                        color: Material.Theme.light.shade(0.87)
                    }
                    Material.Label{
                        id:navlabel
                        text:sectionTitles[page.selectedTab]
                        style:"title"
                        color: Material.Theme.light.shade(0.87)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            Column{
                id:navDrawerContent
                anchors.top: header.bottom
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: parent.width
                Repeater{
                    id:navrep
                    model:sectionsName[page.selectedTab]
                    delegate:ListItem.Standard{
                        text:modelData
                        leftMargin: Material.Units.dp(24)
                        iconName: sectionsIcon[page.selectedTab][index]
                        selected:  page.selectedTab===0 ? page0SelectedIndex === index ? true:false
                        :page.selectedTab===1?page1SelectedIndex ===index ?true:false
                        :page2SelectedIndex===index?true:false;
                        onClicked: {
                            switch(page.selectedTab)
                            {case 0:page0SelectedIndex=index;break;
                             case 1:page1SelectedIndex=index;break;
                             case 2:page2SelectedIndex=index;break;}
                            navigationDrawer.close();
                        }
                    }
                }
            }
            Material.ThinDivider{anchors.bottom: navUser.top }
            ListItem.Standard{
                id:navUser
                height:Material.Units.dp(40);
                anchors.bottom: navGrooveStyle.top
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(16);
                iconName: "awesome/user"
                text:"用 户:"+AppConfig.currentUserName+"/"+AppConfig.currentUserType
            }
            ListItem.Standard{
                id:navGrooveStyle
                height:Material.Units.dp(40);
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Material.Units.dp(8)
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(16);
                iconName: "awesome/road"
                text:"坡口形式 : "+grooveStyleName[AppConfig.currentGroove]
            }
            Keys.onDownPressed: {  switch(page.selectedTab){
                case 0: if(page0SelectedIndex!==navrep.count -1 )page0SelectedIndex++;else page0SelectedIndex=navrep.count-1;break;
                case 1: if(page1SelectedIndex!==navrep.count -1 )page1SelectedIndex++;else page1SelectedIndex=navrep.count-1;break;
                case 2: if(page2SelectedIndex!==navrep.count -1 )page2SelectedIndex++;else page2SelectedIndex=navrep.count-1;break;} }
            Keys.onUpPressed: {switch(page.selectedTab){
                case 0: if(page0SelectedIndex) {page0SelectedIndex--; }else{page0SelectedIndex=0 ;}break;
                case 1: if(page1SelectedIndex) {page1SelectedIndex--; }else{page1SelectedIndex=0 ;}break;
                case 2: if(page2SelectedIndex) {page2SelectedIndex--; }else{page2SelectedIndex=0 ;}break;} }
            Keys.onDigit1Pressed:navigationDrawer.toggle()
            /*Nav关闭时 将焦点转移到选择的Item上 方便按键的对焦*/
            function close() {
                showing = false
                if (parent.hasOwnProperty("currentOverlay")) {
                    parent.currentOverlay = null
                }
                /*找出本次选择的焦点*/
                __lastFocusedItem=Utils.findChild(page.selectedTab===0 ?preConditionTab:page.selectedTab===1?
                                                                             weldAnalyseTab: systemInforTab
                                                  ,sections[page.selectedTab][page.selectedTab===0 ?
                                                                                  page0SelectedIndex  : page.selectedTab===1?
                                                                                      page1SelectedIndex :page2SelectedIndex])
                if (__lastFocusedItem !== null) {
                    __lastFocusedItem.forceActiveFocus()
                    lastFocusedItem=__lastFocusedItem;
                }
                closed()
            }
        }
        onSelectedTabChanged: {
            Qt.inputMethod.hide();
            /*找出本次选择的焦点*/
            lastFocusedItem=Utils.findChild(page.selectedTab === 0 ?preConditionTab:page.selectedTab===1?
                                                                       weldAnalyseTab: systemInforTab
                                            ,sections[page.selectedTab][page.selectedTab===0 ?
                                                                            page0SelectedIndex  : page.selectedTab===1?
                                                                                page1SelectedIndex :page2SelectedIndex])
            if (lastFocusedItem !== null) {
                lastFocusedItem.forceActiveFocus()

            }
        }
        Material.Tab{
            id:preConditionTab
            title: qsTr("预置条件(II)")
            iconName: "action/settings_input_composite"
            Flickable{
                id:preConditionFlickable
                anchors.fill: parent
                clip: true;
                contentHeight: height;
                GrooveCondition{visible: page0SelectedIndex===0}
                TeachCondition{visible: page0SelectedIndex===1}
                WeldCondition{visible: page0SelectedIndex===2}
                GrooveCheck{
                   id:grooveCheck
                   visible: page0SelectedIndex===3
                   grooveStyleModel: grooveStyleList
                   status: app.sysStatus
               }
            }
        }
        Material.Tab{
            id:weldAnalyseTab
            title: qsTr("焊接分析(III)")
            iconName:"awesome/line_chart"
            Flickable{
                id:weldAnalyseFlickable
                anchors.fill: parent
                clip: true;
                contentHeight: height;
                WeldAnalyse{visible: page1SelectedIndex===0;
                weldDataModel: weldDataList
                }
                WeldLine{visible: page1SelectedIndex===1}
            }
        }
        Material.Tab{
            id:systemInforTab
            title: qsTr("系统信息(IV)")
            iconName:"action/dashboard"
            Flickable{
                id:systemInforFlickable
                anchors.fill: parent
                clip: true;
                contentHeight: height;
                SystemInfor{visible: page2SelectedIndex===0}
            }
        }
        Keys.onDigit1Pressed:  navigationDrawer.toggle();
        Keys.onDigit2Pressed: {if((page.selectedTab!=0)&&preConditionTab.enabled)page.selectedTab=0;}
        Keys.onDigit3Pressed: {if((page.selectedTab!=1)&&weldAnalyseTab.enabled)page.selectedTab=1;}
        Keys.onDigit4Pressed: {if((page.selectedTab!=2)&&(systemInforTab.enabled))page.selectedTab=2;}
        Keys.onPressed: {
            switch(event.key){
            case Qt.Key_F6:
                sidebar.expanded=!sidebar.expanded
                event.accepted=true;
                break;
            }
        }
    }
    onSysStatusChanged: {
        if(sysStatus=="0"){
            //高压接触传感
            snackBar.open("焊接系统空闲！")
            //空闲态
            AppConfig.setleds("ready");
        }else if(sysStatus=="1"){
            //高压接触传感
            snackBar.open("坡口检测中，高压输出，请注意安全！")
            AppConfig.setleds("start");
        }else if(sysStatus=="2"){
            //检测完成
            snackBar.open("坡口检测完成！正在计算相关焊接规范。")
            AppConfig.setleds("ready");
            //调用坡口计算函数 生成 坡口参数
        }else if(sysStatus=="3"){
            //启动焊接
            AppConfig.setleds("start");
            //系统焊接中
            snackBar.open("焊接系统焊接中。")
        }else if(sysStatus=="4"){
            //焊接暂停
            AppConfig.setleds("ready");
            //系统焊接中
            snackBar.open("焊接系统焊接暂停。")
        }else if(sysStatus=="5"){
            //系统停止
            AppConfig.setleds("stop");
            //焊接系统停止
              snackBar.open("焊接系统停止。")
        }
    }
    Connections{
        target: ERModbus
        onModbusFrameChanged:{
            if(frame[0]!=="Success"){
                listModel.append({"time":(new Date().toLocaleTimeString(Qt.locale(app.local),"h:mm")),"status":frame.join(",")})
                debug.incrementCurrentIndex();
                app.promise= app.showError("Modbus 通讯异常！",frame[0],"关闭","");
            }else{
                app.closeError();
                //frame[0] 代表状态 1代读取的寄存器地址 2代表返回的 第一个数据 3代表返回的第二个数据 依次递推
                switch(frame[1]){
                    //读取系统状态寄存器地址
                case "0":
                    //判断当前系统状态处于哪一种状态
                    if(app.sysStatus!==frame[2]){
                        if(Number(frame[2])<6)
                            app.sysStatus=frame[2];
                        else{
                            //报错
                        }
                    }else{
                        switch(app.sysStatus){
                            //空闲态
                        case "0":
                            break;
                            //坡口检测态
                        case "1":
                            //读取坡口参数
                            if(frame[3]==="150"){
                                app.modbusExist=false;
                                ERModbus.setmodbusFrame(["R","150",frame[4]])
                            }
                            break;
                            //坡口检测结束态
                        case "2":
                            //读取焊接距离
                            if(frame[3]==="104"){
                                app.modbusExist=false;
                                ERModbus.setmodbusFrame(["R","104",frame[4]])
                            }
                            break;
                            //焊接态
                        case "3":

                            break;
                            //暂停焊接态
                        case "4":
                            break;
                            //焊接停止态
                        case "5":
                            break;
                        }
                    }
                    break;
                    //读取坡口参数寄存器成功
                case "150":
                    console.log(grooveStyleList.count);
                    if(app.sysStatus==="1"){
                        grooveStyleList.append({"ID":frame[2],"C1":frame[3],"C2":frame[4],"C3":frame[5],"C4":frame[6],"C5":frame[7]})
                    }
                    modbusTimer.restart();
                    app.modbusExist=true;
                    break;
                    //读取坡口长度
                case "104":
                    if(app.sysStatus==="2"){

                    }
                    modbusTimer.restart();
                    app.modbusExist=true;
                    break;
                }
            }
        }
    }
    ListModel{
        id:listModel
        ListElement{
            time:"00:00"
            status:"System Start"
        }
    }
    Material.Snackbar{
            id:snackBar
            fullWidth:false
            duration:3000;
    }
    Material.Sidebar{
        id:sidebar
        header:qsTr("系统状态")
        mode:"right"
        expanded: false
        width:Material.Units.dp(300)
        autoFlick:false
        contents:ListView{
            id:debug
            anchors.fill: parent
            model:listModel
            delegate: Material.Label{
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(16)
                text:time +":"+status
                style: "body1"
            }
            onCurrentIndexChanged: {
                if(currentIndex>1000){
                    listModel.remove(0);
                }
            }
        }
    }
    InputPanel{
        id:input
        objectName: "InputPanel"
        visible: Qt.inputMethod.visible
        onVisibleChanged: {
            if(!visible){
                /*找出本次选择的焦点*/
                if (lastFocusedItem !== null) {
                    lastFocusedItem.forceActiveFocus()
                }
            }
        }
        y: Qt.inputMethod.visible ? parent.height - input.height:parent.height
        Behavior on y{
            NumberAnimation { duration: 200 }
        }
    }
    /**/
    Component.onCompleted: {
        /*打开数据库*/
        Material.UserData.openDatabase();
        var result=Material.UserData.getResultFromFuncOfTable("AccountTable","","");
        var name,type,password;
        for(var i=0;i<result.rows.length;i++){
            name = result.rows.item(i).id;
            type=result.rows.item(i).type;
            password=result.rows.item(i).password;
            namemodel.append({"text":name})
            accountmodel.append( {"name":name,"type":type,"password":password});
            if(name === accountname.text){
                changeuserFeildtext.selectedIndex = i+1;
                changeuserFeildtext.helperText=type;
                AppConfig.currentUserPassword =password;
            }
        }
        namemodel.remove(0)
        accountmodel.remove(0);
        /*写入系统背光值*/
        AppConfig.backLight=AppConfig.backLight;
    }
    /*日历*/
    Material.Dialog {
        id:datePickerDialog; hasActions: true; contentMargins: 0;floatingActions: true
        negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        Material.DatePicker {
            frameVisible: false;dayAreaBottomMargin : Material.Units.dp(48);isLandscape: true;
        }
    }
    /*背光调节*/
    Material.Dialog{
        id:backlight
        title: qsTr("背光调节");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        dialogContent: Item{
            height:Material.Units.dp(100);
            width:Material.Units.dp(240);
            Material.Slider {
                id:backlightslider;width:Material.Units.dp(240);anchors.top: parent.top;anchors.topMargin: Material.Units.dp(24)
                value:AppConfig.backLight;stepSize: 5;numericValueLabel: true;
                minimumValue: 5;maximumValue: 100; activeFocusOnPress: true;
                onVisibleChanged: {if(visible){forceActiveFocus()}}}}
        onAccepted: {AppConfig.backLight=backlightslider.value}
        onRejected: {backlightslider.value=AppConfig.backLight}
    }
    /*颜色选择对话框*/
    Material.Dialog {
        id: colorPicker;title: qsTr("主题");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        /*接受则存储系统颜色*/
        onAccepted:{AppConfig.themePrimaryColor=theme.primaryColor;AppConfig.themeAccentColor=theme.accentColor;AppConfig.themeBackgroundColor=theme.backgroundColor; }
        /*不接受则释放系统颜色*/
        onRejected: {theme.primaryColor=AppConfig.themePrimaryColor;theme.accentColor=AppConfig.themeAccentColor;theme.backgroundColor=AppConfig.themeBackgroundColor; }
        /*下拉菜单*/
        Material.MenuField { id: selection; model: ["基本色彩", "前景色彩", "背景色彩"]; width: Material.Units.dp(160)}
        Grid {
            columns: 7
            spacing: Material.Units.dp(8)
            Repeater {
                model: [
                    "red", "pink", "purple", "deepPurple", "indigo",
                    "blue", "lightBlue", "cyan", "teal", "green",
                    "lightGreen", "lime", "yellow", "amber", "orange",
                    "deepOrange", "grey", "blueGrey", "brown", "black",
                    "white"
                ]
                Rectangle {
                    width: Material.Units.dp(30)
                    height: Material.Units.dp(30)
                    radius: Material.Units.dp(2)
                    color: Material.Palette.colors[modelData]["500"]
                    border.width: modelData === "white" ? Material.Units.dp(2) : 0
                    border.color: Material.Theme.alpha("#000", 0.26)
                    Material.Ink {
                        anchors.fill: parent
                        onPressed: {
                            switch(selection.selectedIndex) {
                            case 0:
                                theme.primaryColor = parent.color
                                break;
                            case 1:
                                theme.accentColor = parent.color
                                break;
                            case 2:
                                theme.backgroundColor = parent.color
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    /*更换用户对话框*/
    Material.Dialog{
        id:changeuser;
        width:Material.Units.dp(300)
        title:qsTr("更换用户");negativeButtonText:qsTr("取消");positiveButtonText:qsTr("确定");
        positiveButtonEnabled:false;
        onAccepted: {
            AppConfig.currentUserName = changeuserFeildtext.selectedText;
            AppConfig.currentUserType = changeuserFeildtext.helperText; }
        onRejected: {
            changeuserFeildtext.helperText = AppConfig.currentUserType;
            for(var i=0;i<100;i++){
                if(accountname.text === accountmodel.get(i).name ){
                    changeuserFeildtext.selectedIndex = i;
                    break; }
            }
        }
        ListModel{id:accountmodel;ListElement{name:"user";type:"user";password:"user"}}
        ListModel{id:namemodel;ListElement{text:"user"}}
        dialogContent: [
            Material.MenuField{id:changeuserFeildtext;
                floatingLabel:true;
                model:namemodel
                placeholderText:qsTr("用户名:");
                width:parent.width
                onItemSelected:  {
                    password.enabled=true;
                    var data=accountmodel.get(index);
                    AppConfig.currentUserPassword = data.password;
                    AppConfig.currentUserType=changeuserFeildtext.helperText = data.type;
                    password.text="";}},
            Material.TextField{id:password;
                floatingLabel:true;
                placeholderText:qsTr("密码:");
                characterLimit: 8;
                width:parent.width
                onTextChanged:{
                    if(password.text=== AppConfig.currentUserPassword){
                        changeuser.positiveButtonEnabled=true;
                        password.helperText.color="green";
                        password.helperText=qsTr("密码正确");}
                    else{changeuser.positiveButtonEnabled=false;
                        password.helperText=qsTr("请输入密码...");}}
                onHasErrorChanged: {
                    if(password.hasError === true){
                        password.helperText =qsTr( "密码超过最大限制");}}
            } ]
    }
    /*语言对话框*/
    Material.Dialog{  id:languagePicker;
        title:qsTr("更换语言");negativeButtonText:qsTr("取消");positiveButtonText:qsTr("确定");
        Column{
            width: parent.width
            spacing: 0
            Repeater{
                model: [qsTr("汉语"),qsTr("英语")];
                ListItem.Standard{
                    text:modelData;
                    showDivider:true;
                }
            }
        }
    }
}
