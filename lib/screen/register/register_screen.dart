import 'package:flutter/material.dart';
import 'package:wb_cmu/screen/register/success_screen.dart';
import 'package:wb_cmu/constant.dart';
import 'package:wb_cmu/model/user.dart';
import 'package:wb_cmu/db/weight_database.dart';
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  late String name;
  late String surname;
  late int age ;
  late String gender;
  String  dropdownValue = 'เพศ';
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: mPrimaryColor),
      body: Form(
        key: _formKey,
        child: Container(
            padding: const EdgeInsets.all(50),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(

                      child: Text("ลงทะเบียนผู้ใช้ใหม่",style: TextStyle(color: mPrimaryColor , fontSize: 30)),
                    )
                ),
                TextFormField(
                  onChanged: (val){
                    setState(() {
                      name = val ;
                    });
                  },
                  // The validator receives the text that the user has entered.
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'ชื่อ' , hintStyle: TextStyle(color: mSecondaryColor)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  // The validator receives the text that the user has entered.
                  onChanged: (val){
                    setState(() {
                      surname = val ;
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'นามสกุล' , hintStyle: TextStyle(color: mSecondaryColor)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                        child:TextFormField(
                          keyboardType: TextInputType.number,
                          onChanged: (val){
                            setState(() {
                              age = int.parse(val);

                            });
                          },
                          // The validator receives the text that the user has entered.
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), hintText: 'อายุุ' , hintStyle: TextStyle(color: mSecondaryColor)
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        )
                    ),
                    SizedBox(width: 30)
                    ,
                    Flexible(
                      // child:TextFormField(
                      //   // The validator receives the text that the user has entered.
                      //   decoration: InputDecoration(
                      //       border: OutlineInputBorder(), hintText: 'เพศ' , hintStyle: TextStyle(color: mSecondaryColor)
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter some text';
                      //     }
                      //     return null;
                      //   },
                      // )
                      child: Container(

                        child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(

                              hint:Text("เพศ" , style: TextStyle(color: mSecondaryColor)),
                              isExpanded: true,
                              value: null ??dropdownValue  ,
                              elevation: 16,
                              style: TextStyle(color: mSecondaryColor),


                              items: <String>['เพศ','ชาย', 'หญิง', 'ไม่ระบุ']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                  gender = dropdownValue;
                                });
                              },
                            )
                        ),
                      ),
                    )
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

                    onPressed: registerUser,
                    child: Text('ลงทะเบียน',style: TextStyle(color: Colors.white , fontSize: 20)),
                  ),
                )
              ],

            )

        ),
      )

    );
  }
  void registerUser() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {

      final newUser = await createUser();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen(user: newUser)),
      );
      }
    }

  Future createUser() async {
    final user = User(name: name, surname: surname, gender: gender, age: age, createAt: DateTime.now());
    await WeightDatabase.instance.createUser(user);
    return user;
  }
}
