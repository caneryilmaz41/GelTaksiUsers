
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_app/authentication/login_screen.dart';
import 'package:user_app/splash_Screen/splash_screen.dart';

import '../global/global.dart';
import '../utils/constants.dart';
import '../widgets/progress_dialog.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameTextEditingController=TextEditingController();
  TextEditingController emailTextEditingController=TextEditingController();
  TextEditingController phoneTextEditingController=TextEditingController();
  TextEditingController passwordTextEditingController=TextEditingController();
  validateForm(){

    if(nameTextEditingController.text.length<3){
      Fluttertoast.showToast(msg: 'İsminiz en az 3 karakter içermelidir.');
    }else if(!emailTextEditingController.text.contains('@')){
      Fluttertoast.showToast(msg: 'Geçersiz email adresi');
    }else if(phoneTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: 'Telefon numarası boş bırakılamaz.');
    }else if(passwordTextEditingController.text.length<6){
      Fluttertoast.showToast(msg: 'Parolanız en az 6 karakter içermelidir.');
    }
    else{
      saveUserInfoNow();
    }
  }
  saveUserInfoNow()async{
    showDialog(
        context:context,
        barrierDismissible:false,
        builder:(BuildContext c){
          return ProgressDialog(message:'İşlem devam ediyor,Lütfen bekleyin',);
        }
      );
      final User? firebaseUser=(
        await fAuth.createUserWithEmailAndPassword(
          email:emailTextEditingController.text.trim(),
          password:passwordTextEditingController.text.trim()

        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'Hata: '+msg.toString());
        })
      ).user;
      if(firebaseUser!=null){
        Map userMap={
          "id":firebaseUser.uid,
          "name":nameTextEditingController.text.trim(),
          "email":emailTextEditingController.text.trim(),
          "phone":phoneTextEditingController.text.trim()
        };
      DatabaseReference reference= FirebaseDatabase.instance.ref().child("users");
      reference.child(firebaseUser.uid).set(userMap);
      currenFirebaseUser=firebaseUser;
      Fluttertoast.showToast(msg: 'Hesabınız başarılı bir şekilde oluşturuldu');
      Navigator.push(context, MaterialPageRoute(builder:(c)=>MySplashScreen()));
      
      }else{
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Hesap oluşturulamadı.');
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset('images/customer.png'),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  textAlign: TextAlign.center,
                  'Üye Ol',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                TextField(
                  style:TextStyle(color:Colors.grey),
                  controller:nameTextEditingController,
                  decoration:const InputDecoration(
                    labelText:'Ad',
                    hintText:'Ad',
                    enabledBorder:UnderlineInputBorder(
                      borderSide:BorderSide(color:Colors.grey)
                    ),
                    focusedBorder:UnderlineInputBorder(
                      borderSide:BorderSide(color:Colors.grey)
                    ),
                    hintStyle:TextStyle(color: Colors.grey,fontSize:10),
                    labelStyle:TextStyle(color: Colors.grey,fontSize:14)
          
                  ),
                ),
                TextField(
                  keyboardType:TextInputType.emailAddress,
                  style:TextStyle(color:Colors.grey),
                  controller:emailTextEditingController,
                  decoration:const InputDecoration(
                    labelText:'Email',
                    hintText:'Email',
                    enabledBorder:UnderlineInputBorder(
                      borderSide:BorderSide(color:Colors.grey)
                    ),
                    focusedBorder:UnderlineInputBorder(
                      borderSide:BorderSide(color:Colors.grey)
                    ),
                    hintStyle:TextStyle(color: Colors.grey,fontSize:10),
                    labelStyle:TextStyle(color: Colors.grey,fontSize:14)
          
                  ),
                ),
                TextField(
                  keyboardType:TextInputType.phone,
                  style:TextStyle(color:Colors.grey),
                  controller:phoneTextEditingController,
                  decoration:const InputDecoration(
                    labelText:'Telefon',
                    hintText:'Telefon',
                    enabledBorder:UnderlineInputBorder(
                      borderSide:BorderSide(color:Colors.grey)
                    ),
                    focusedBorder:UnderlineInputBorder(
                      borderSide:BorderSide(color:Colors.grey)
                    ),
                    hintStyle:TextStyle(color: Colors.grey,fontSize:10),
                    labelStyle:TextStyle(color: Colors.grey,fontSize:14)
          
                  ),
                ),
                TextField(
                  obscureText:true,
                  style:TextStyle(color:Colors.grey),
                  controller:passwordTextEditingController,
                  decoration:const InputDecoration(
                    labelText:'Parola',
                    hintText:'Parola',
                    enabledBorder:UnderlineInputBorder(
                      borderSide:BorderSide(color:Colors.grey)
                    ),
                    focusedBorder:UnderlineInputBorder(
                      borderSide:BorderSide(color:Colors.grey)
                    ),
                    hintStyle:TextStyle(color: Colors.grey,fontSize:10),
                    labelStyle:TextStyle(color: Colors.grey,fontSize:14)
          
                  ),
                ),
              const SizedBox(height: 20,),
                ElevatedButton(onPressed:(){
                  validateForm();
                  //Navigator.push(context, MaterialPageRoute(builder:(c)=>CarInfoScreen()));
                }, 
                style:ElevatedButton.styleFrom(
                  primary:mycolor 
                ),
                child:Text(
                    'Hesap Oluştur',style:TextStyle(
                      color:mainColor,
                      fontSize:18
                    ),
                )),
                TextButton(onPressed: (){ 
                  Navigator.push(context, MaterialPageRoute(builder:(c)=>LoginScreen()));
                }, child: Text('Hesabın zaten var mı?',style:TextStyle(color:Colors.grey),))
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
