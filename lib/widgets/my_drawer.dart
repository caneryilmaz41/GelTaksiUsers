import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:user_app/global/global.dart';
import 'package:user_app/splash_Screen/splash_screen.dart';

class MyDrawer extends StatefulWidget {
     String? name;
     String? email;
     MyDrawer({this.email,this.name});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:ListView(
        children: [
          Container(
            height:165,
            color:Colors.grey,
            child:DrawerHeader(
              decoration:BoxDecoration(
              color:Colors.black,
                
              ),
              child:Row(
                children: [
                  Icon(Icons.person,size: 80,color:Colors.grey,),
                 const SizedBox(width:16,),
                  Column(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      Text(widget.name.toString(),style: TextStyle(fontSize: 16,color:Colors.grey,fontWeight:FontWeight.bold),),
                      const SizedBox(height:10,),
                      Text(widget.name.toString(),style: TextStyle(fontSize: 12,color:Colors.grey,),)
                    ],
                  )
                ],
              ) ,
            ),
          ),
          GestureDetector(
            onTap:() {
              
            },
            child:ListTile(
              leading:Icon(Icons.history,color:Colors.white54),
              title:Text('History',style:TextStyle(color:Colors.white54),),
            ),
          ),
           GestureDetector(
            onTap:() {
              
            },
            child:ListTile(
              leading:Icon(Icons.person,color:Colors.white54),
              title:Text('Profile',style:TextStyle(color:Colors.white54),),
            ),
          ),
           GestureDetector(
            onTap:() {
              
            },
            child:ListTile(
              leading:Icon(Icons.info,color:Colors.white54),
              title:Text('Hakkında',style:TextStyle(color:Colors.white54),),
            ),
          ), GestureDetector(
            onTap:() {
              fAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder:(c)=>MySplashScreen()));
            },
            child:ListTile(
              leading:Icon(Icons.logout,color:Colors.white54),
              title:Text('Çıkış',style:TextStyle(color:Colors.white54),),
            ),
          )
        ],
      ),
    );
  }
}