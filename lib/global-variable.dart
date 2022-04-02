library my_prj.globals;
import 'package:wb_cmu/model/user.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

late User user;
bool isLoggedIn = false;
late BluetoothDevice selectedDevice ;
bool isConnected = false;
bool changeToText = false;
bool isStartMeasure =false;
String pathUser = "";
String pathTest = "";
int deviceId = 1 ;
String FileName = "user";