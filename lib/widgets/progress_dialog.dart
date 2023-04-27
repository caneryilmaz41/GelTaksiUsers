
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/constants.dart';

class ProgressDialog extends StatelessWidget {
 String? message;
 ProgressDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return  Dialog(
      //backgroundColor:mainColor,
      child:Container(
        margin:const EdgeInsets.all(16.0),
        decoration:BoxDecoration(
          color:Colors.white,
          borderRadius:BorderRadius.circular(6)
        ),
        child:Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
            const SizedBox(width:6,),
              CircularProgressIndicator(
                valueColor:AlwaysStoppedAnimation<Color>(mycolor),
              ),
              const  SizedBox(width: 26,),
               Text(
                message!,
                style:const TextStyle(
                  color:Colors.black,
                  fontSize: 15,

                ),

               )
            ],
          ),
        ),
      ),
    );
  }
}