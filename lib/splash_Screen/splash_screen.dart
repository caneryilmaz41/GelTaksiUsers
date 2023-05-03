import 'dart:async';
import 'package:flutter/material.dart';
import 'package:user_app/assistans/assistants_methods.dart';
import 'package:user_app/authentication/login_screen.dart';
import 'package:user_app/mainScreens/main_screen.dart';

import '../global/global.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

    startTimer(){
     fAuth.currentUser!=null? AssistanMethods.readCurrentOnlineUserInfo():null;
      Timer(const Duration(seconds:3),()async{
        if(await fAuth.currentUser!=null){
          currenFirebaseUser=fAuth.currentUser;
          Navigator.push(context, MaterialPageRoute(builder:(c)=>   (
          MainScreen()
        )));
        }else{
          Navigator.push(context, MaterialPageRoute(builder:(c)=>   (
          LoginScreen()
        )));
        }
        
      });
    }
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color:Colors.black,
        child:Center(
          child:Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Image.asset('images/taxi-driver.png'),
              const SizedBox(height: 10,),
              const Text('Ferofen Taksiye Hoşgeldiniz',
              style:TextStyle(
                color:Colors.white,
                fontSize:20,
                fontWeight: FontWeight.bold
              ),)
            ],
          ),
        ),
      ),
    );
  }
}