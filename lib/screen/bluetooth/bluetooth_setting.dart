import 'package:flutter/material.dart';
import 'package:wb_cmu/constant.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wb_cmu/screen/home/home_screen.dart';
import 'SelectBondedDevicePage.dart';
import 'ChatPage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'package:wb_cmu/global-variable.dart' as globals;
import 'package:wb_cmu/screen/main/main_screen.dart';
import 'package:wb_cmu/screen/selectDevice/select_device_screen.dart';
class BluetoothSetting extends StatefulWidget {
  @override
  _BluetoothSettingState createState() => _BluetoothSettingState();
}

class _BluetoothSettingState extends State<BluetoothSetting> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;
  bool isConnected = false;
  // BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;
  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: mPrimaryColor,
            leading:  new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () => Navigator.push(
                  context,MaterialPageRoute(builder: (context) => MainScreen(user: globals.user))
              ),
            )),
        body: ListView(
          children: <Widget>[
            Container(
                padding: const EdgeInsets.fromLTRB(30, 15, 10,0),
                child:Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/bluetooth-b-brands.svg',fit: BoxFit.cover, // this is the solution for border
                            width: 50, color:mSecondaryColor),
                        SizedBox(width: 30),
                        Flexible(child: Text("ตั้งค่า Bluetooth",style: TextStyle(color: mPrimaryColor , fontSize: 30)))
                      ],
                    ),
                    SizedBox(height: 30),
                  ],

                )

            ),

            // Divider(),

            SwitchListTile(
              title: Text('Enable Bluetooth',style: TextStyle(color: mPrimaryColor , fontSize: 25)),
              value: _bluetoothState.isEnabled,
              activeColor: mSecondaryColor,
              inactiveThumbColor: mSecondaryColor,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }
                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: Text('Bluetooth Status',style: TextStyle(color: mPrimaryColor , fontSize: 25)),
              subtitle: Text(_bluetoothState.toString(),style: TextStyle(color: mSecondaryColor )),
              trailing: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(mSecondaryColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                    )
                ),
                child: const Text('Paired Device'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            // SwitchListTile(
            //   title: const Text('Auto-try specific pin when pairing'),
            //   subtitle: const Text('Pin 1234'),
            //   value: _autoAcceptPairingRequests,
            //   onChanged: (bool value) {
            //     setState(() {
            //       _autoAcceptPairingRequests = value;
            //     });
            //     if (value) {
            //       FlutterBluetoothSerial.instance.setPairingRequestHandler(
            //               (BluetoothPairingRequest request) {
            //             print("Trying to auto-pair with Pin 1234");
            //             if (request.pairingVariant == PairingVariant.Pin) {
            //               return Future.value("1234");
            //             }
            //             return Future.value(null);
            //           });
            //     } else {
            //       FlutterBluetoothSerial.instance
            //           .setPairingRequestHandler(null);
            //     }
            //   },
            // ),
            ListTile(
              title: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(mSecondaryColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                    )
                ),
                child: const Text('Connect to paired device'),
                onPressed: () async {
                  final BluetoothDevice? selectedDevice =
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectBondedDevicePage(checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    print('Connect -> selected ' + selectedDevice.address);
                    globals.selectedDevice = selectedDevice ;
                    globals.isConnected = true;
                  } else {
                    print('Connect -> no device selected');
                  }
                },
              ),
              // subtitle: isConnected ? Text('Connect to ' + globals.selectedDevice.name.toString()): Text('')
            ),
            // isConnected ? Text('Connect to ' + globals.selectedDevice.name.toString()):null
          ],

        )
    );
  }
}
