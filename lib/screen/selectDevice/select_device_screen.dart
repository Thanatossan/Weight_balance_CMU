
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:wb_cmu/screen/main/main_screen.dart';
import 'package:wb_cmu/screen/home/home_screen.dart';
import 'package:wb_cmu/constant.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wb_cmu/model/user.dart';
import 'package:wb_cmu/screen/bluetooth/bluetooth_setting.dart';
import 'package:wb_cmu/global-variable.dart' as globals;
class selectDeviceScreen extends StatelessWidget {
  final User user;
  const selectDeviceScreen({
    Key? key,
    required this.user
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: mPrimaryColor,
        leading:  new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen())
            );
          }
          ,
        ),
        actions: [
          Padding(
              padding: EdgeInsets.all(15),
              child: GestureDetector(
                  onTap: () {},
                  child:
                  Text("ชื่อ: "+ user.name +" "+ user.surname,style: TextStyle(fontSize: 18),)
              )
          )
        ],
      ),

      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(

              child: SvgPicture.asset('assets/icons/home_logo.svg'),
            ),
            Line(),
            Row(
              children: [
                SvgPicture.asset('assets/icons/cog-solid.svg',fit: BoxFit.cover, // this is the solution for border
                    width: 50, color:mSecondaryColor),
                SizedBox(width: 30),
                Flexible(child: Text("Select Device",style: TextStyle(color: mPrimaryColor , fontSize: 35)))
              ],
            ),

            DropdownWidget(),

          ],
        ),
      ),
      bottomNavigationBar: ButtonAppBluetooth(),
    );
  }
}

class DropdownWidget extends StatefulWidget {
  const DropdownWidget({Key? key}) : super(key: key);

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  int id = 1;
  var devices =  ['Device 1','Device 2','Device 3','Device 4','Device 5','Device 6'];
  String dropdownValue = 'Device 1';
  @override
  Widget build(BuildContext context) {

    return Column(
        children: [

        Container(
          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 80),
          child:DropdownButtonHideUnderline(
    child: DropdownButton<String>(

      isExpanded: true,
      value: null ??dropdownValue  ,
      elevation: 16,
      style: TextStyle(color: mSecondaryColor , fontSize: 25),
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

        });
      },
    )
    )
        )
    ,
          Container(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
            constraints: BoxConstraints.tightFor(width: 250, height: 100),
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(mSecondaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
              onPressed: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(builder: (context) => MainScreen(user: globals.user))
                );

              },
              child: Text('Continue',style: TextStyle( fontSize: 25)),
            ),
          )],
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





// ignore: must_be_immutable
class ButtonAppBluetooth extends StatefulWidget {


  @override
  _ButtonAppBluetoothState createState() => _ButtonAppBluetoothState();
}

class _ButtonAppBluetoothState extends State<ButtonAppBluetooth> {

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: mSecondaryColor,
      // child: Text("สถานะเชื่อมต่อ Bluetooth : ",style: TextStyle(
      //   fontSize: 15 , color: Colors.white
      // ),
      // )
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
            child: Icon(Icons.bluetooth, color: Colors.white),
          ),

          Text("สถานะ Bluetooth :",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 10, 15),
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(mPrimaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BluetoothSetting()),
                );
              },

              child: globals.isConnected? Text('เชื่อมต่อแล้ว'):Text('ตั้งค่า'),
            ),

          ),
        ],
      ),
    );
  }
}
