import 'package:flutter/material.dart';
import 'package:wb_cmu/constant.dart';
import 'package:wb_cmu/screen/home/home_screen.dart';
import 'package:wb_cmu/model/user.dart';
class SuccessScreen extends StatelessWidget {
  final User user;
  const SuccessScreen({
    Key? key,
    required this.user
}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(backgroundColor: mPrimaryColor),
      body: Container(
          padding: const EdgeInsets.all(50),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    // child: Text('ลงทะเบียนผู้ใช้ใหม่',textAlign: TextAlign.center),
                    child: Text("ลงทะเบียนสำเร็จ",style: TextStyle(color: mSecondaryColor , fontSize: 30)),
                  )
              ),
              Row(
                children: [
                  Text("ชื่อ",style: TextStyle(color: mSecondaryColor , fontSize: 30)),
                  SizedBox(width: 10),
                  Text(user.name,style: TextStyle(color: mPrimaryColor , fontSize: 30))
                ],
              ),
              Row(
                children: [
                  Text("นามสกุล",style: TextStyle(color: mSecondaryColor , fontSize: 30)),
                  SizedBox(width: 10),
                  Text(user.surname,style: TextStyle(color: mPrimaryColor , fontSize: 30))
                ],
              ),
              Row(
                children: [
                  Text("เพศ",style: TextStyle(color: mSecondaryColor , fontSize: 30)),
                  SizedBox(width: 10),
                  Text(user.gender,style: TextStyle(color: mPrimaryColor , fontSize: 30))
                ],
              ),
              Row(
                children: [
                  Text("อายุ",style: TextStyle(color: mSecondaryColor , fontSize: 30)),
                  SizedBox(width: 10),
                  Text(user.age.toString(),style: TextStyle(color: mPrimaryColor , fontSize: 30))
                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                constraints: BoxConstraints.tightFor(width: 250, height: 100),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text('กลับสู่หน้าแรก',style: TextStyle(color: Colors.white , fontSize: 20)),
                ),
              )
            ],

          )

      ),
    );
  }
}
