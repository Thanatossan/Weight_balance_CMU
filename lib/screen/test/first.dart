import 'dart:ffi';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:wb_cmu/constant.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:wb_cmu/model/user.dart';
import 'package:wb_cmu/model/weightTest.dart';
import 'dart:typed_data';
import 'package:wb_cmu/global-variable.dart' as globals;
import 'dart:math';
import 'dart:typed_data';
import 'package:wb_cmu/db/weight_database.dart';

bool isStartMeasure = false;
class DropdownWidget extends StatefulWidget {
  const DropdownWidget({Key? key}) : super(key: key);

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  int id = 1;

  String dropdownValue = 'Device 1';
  @override
  Widget build(BuildContext context) {

    return
      DropdownButton<String>(
                  // isExpanded: true,
                  value: null ??dropdownValue  ,
                  icon:  const Icon(Icons.arrow_downward,color: Colors.white),
                  dropdownColor: mPrimaryColor,
                  elevation: 16,
                  style: TextStyle(color: mFourthColor , fontSize: 18),
                  items: <String>['Device 1','Device 2','Device 3','Device 4','Device 5','Device 6','Device 7','Device 8','Device 9','Device 10']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;

                      globals.deviceId = stringToInt(dropdownValue);
                      isStartMeasure = false;
                    });
                  },
                );
  }
  int stringToInt(String dropdownValue){
    int value = 0;
    String delimiter = " ";
    int firstIndex = dropdownValue.indexOf(delimiter);
    String stringId = dropdownValue.substring(firstIndex+1,dropdownValue.length);
    value = int.parse(stringId);
    return value;
  }
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}
class FirstTestScreen extends StatelessWidget {
  final User user;
  const FirstTestScreen({
    Key? key,
    required this.user
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(backgroundColor: mPrimaryColor,
        // title: Text("Device : Device ${globals.deviceId}",style: TextStyle(fontSize: 18)),
        title:
        SizedBox(
            child: DropdownWidget()
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.all(15),
              child: GestureDetector(
                  onTap: () {},
                  child:
                  Text("ชื่อ: "+ user.name +" "+ user.surname,style: TextStyle(fontSize: 18))
              )
          )
        ],),
      body: Container(
          padding: const EdgeInsets.all(0),
          child: Container(
              child:Column(
                children: [


                  SizedBox(height: 30),
                  // StatefulComponent()
                  StatefulCom()

                ],

              )

          )

      ),
    );
  }
}

class StatefulCom extends StatefulWidget {
  final BluetoothDevice server = globals.selectedDevice;
  @override
  _StatefulComState createState() => _StatefulComState();
}

class _StatefulComState extends State<StatefulCom> {


  static final clientID = 0;
  BluetoothConnection? connection;
  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;
  String stringMessage = "";
  double newton = 0.0;
  double leftNewton = 0.0;
  double rightNewton = 0.0;
  double endRightNewton=0.0;
  double endLeftNewton =0.0;
  int id = 0;
  double valueLeft = 0.0;
  double valueRight = 0.0;
  Color currentColor = Colors.redAccent;
  double lastCorrectLeft = 0.0;
  double lastCorrectRight = 0.0;
  Image imagePointerStart = Image.asset(
    'assets/icons/start.png',
    fit: BoxFit.cover, // this is the solution for border
    width: 100,
  );
  Image imagePointer = Image.asset(
    'assets/icons/start.png',
    fit: BoxFit.cover,
    width: 100,
  );
  void initState() {
    super.initState();
    connectDevice();
  }
  void connectDevice() async{
    await EasyLoading.show();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
    await EasyLoading.dismiss();
  }
  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    isStartMeasure = false;
    super.dispose();
  }
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    // print(dataString);
    int index = buffer.indexOf(13);
    if (~index != 0) {

      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ?
            _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );

        if(backspacesCounter>0){
          stringMessage = _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter);
        }
        else{
          stringMessage = _messageBuffer + dataString.substring(0, index);
        }
        stringMessage = stringMessage.trim();

        if(stringMessage.length<50){

          print(stringMessage);
          stringMessage = stringMessage.trim();
          String delimiter = ";";
          int firstIndex = stringMessage.indexOf(delimiter);
          if(firstIndex != -1){

            String stringId = stringMessage.substring(0,firstIndex);
            String stringValue = stringMessage.substring(firstIndex+1,stringMessage.length);
            int lastIndex = stringValue.indexOf(delimiter);
            if(lastIndex != -1){
              String stringLeft = stringValue.substring(0,lastIndex);
              String stringRight = stringValue.substring(lastIndex+1,stringValue.length);
              try{
                id = int.parse(stringId);
                if(id == globals.deviceId){

                  leftNewton = double.parse((double.parse(stringLeft) / 1000).toStringAsFixed(0)) ;
                  rightNewton = double.parse((double.parse(stringRight) / 1000).toStringAsFixed(0));

                  if(leftNewton<0){
                    leftNewton = 0;
                  }
                  if (rightNewton<0){
                    rightNewton = 0;
                  }
                  leftNewton = leftNewton.abs();
                  rightNewton = rightNewton.abs();
                  lastCorrectLeft = leftNewton;
                  lastCorrectRight = rightNewton;

                }
                else{

                  leftNewton =lastCorrectLeft;
                  rightNewton =lastCorrectRight;
                }

                if((rightNewton - leftNewton).abs() > 5){
                  currentColor = Colors.redAccent;
                  imagePointer = Image.asset(
                    'assets/icons/off_threshold.png',
                    fit: BoxFit.cover, // this is the solution for border
                    width: 100,
                  );
                }else{
                  currentColor = mPrimaryColor;
                  imagePointer = Image.asset(
                    'assets/icons/on_threshold.png',
                    fit: BoxFit.cover, // this is the solution for border
                    width: 100,
                  );
                }
              }catch(e){
                id = id;
                leftNewton = leftNewton;
                rightNewton = rightNewton;
              }
            }
          }
        }


        _messageBuffer = dataString.substring(index);

      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    // print(messages.map((_message) =>
    // _message.text.trim()));


  }
  Future createTest() async{
    final weightTest = WeightTest(userId: globals.user.id, time: DateTime.now(),deviceId : globals.deviceId, type: "แรงกด", leftKilogram: leftNewton, rightKilogram: rightNewton, total: leftNewton+rightNewton);
    await WeightDatabase.instance.addTest(weightTest);
    return weightTest;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
        child: Row(
          children: [
            Expanded(child:  Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: Text("ซ้าย".toString(),style: TextStyle(color: mSecondaryColor , fontSize: 60)))

            ),

            Divider(
                color: Colors.black
            ),
            Expanded(child:  Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: Text("ขวา".toString(),style: TextStyle(color: mSecondaryColor , fontSize: 60)))
            ),
          ],
        )
    ),
        Container(
            height: 350,
            child: Row(
              children: [
                Expanded(child:  SfLinearGauge(
                    markerPointers: [
                      isStartMeasure ?

                      // LinearShapePointer(value: leftNewton, height: 30, width: 40,color: currentColor, )
                      //     :LinearShapePointer(value: endLeftNewton, height: 30, width: 40,color: currentColor, )
                      LinearWidgetPointer(
                          value: leftNewton,
                          child: imagePointer
                      ):LinearWidgetPointer(
                          value: endLeftNewton,
                          child: imagePointerStart
                      )
                    ],
                    barPointers: [
                      isStartMeasure ?
                      LinearBarPointer(
                          value: leftNewton,
                          //Change the color
                          color: currentColor
                      ):LinearBarPointer(
                          value: endLeftNewton,
                          //Change the color
                          color: currentColor
                      )
                    ],
                    orientation: LinearGaugeOrientation.vertical,
                  interval: 20,
                    showLabels: false
                ),

                ),

                Divider(
                    color: Colors.black
                ),
                Expanded(child:  SfLinearGauge(
                    markerPointers: [isStartMeasure ?
                    LinearWidgetPointer(
                        value: rightNewton,
                        child: imagePointer
                    ):LinearWidgetPointer(
                        value: endRightNewton,
                        child: imagePointerStart
                    )
                    ],
                    barPointers: [
                      isStartMeasure ?
                      LinearBarPointer(
                          value: rightNewton,
                          //Change the color
                          color: currentColor
                      ):LinearBarPointer(
                          value: endRightNewton,
                          //Change the color
                          color: currentColor
                      )
                    ],
                    orientation: LinearGaugeOrientation.vertical,
                    interval: 20,
                    showLabels: false
                ),
                ),
              ],
            )
        ),

        Row(
          children: [
            Expanded(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(

                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: currentColor,width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                  ),
                  child: !isStartMeasure? Text(endLeftNewton.toStringAsFixed(0),style: TextStyle(color: currentColor , fontSize: 40)):
                  Text(leftNewton.toStringAsFixed(0),style: TextStyle(color: currentColor , fontSize: 40)),
                )
              ],
            ))
            ,Expanded(child: Row(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(

                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: currentColor,width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                  ),
                  child: !isStartMeasure? Text(endRightNewton.toStringAsFixed(0),style: TextStyle(color: currentColor , fontSize: 40)):
                  Text(rightNewton.toStringAsFixed(0),style: TextStyle(color: currentColor , fontSize: 40)),
                )
              ],
            ))



          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          constraints: BoxConstraints.tightFor(width: 250, height: 110),
          child:ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(mSecondaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    )
                )
            ),
            onPressed: () {
              isStartMeasure = !isStartMeasure;
              if(isStartMeasure == false){
                endLeftNewton = leftNewton;
                endRightNewton = rightNewton;
                createTest();
                print("create Test!");
              }
              print(isStartMeasure);
            },

            child:
                !isStartMeasure?
                Text("เริ่มต้น",style: TextStyle(color: Colors.white , fontSize: 25)) :
              Text("หยุด",style: TextStyle(color: Colors.white , fontSize: 25))

          ),
        )
      ],
    );
  }
}
