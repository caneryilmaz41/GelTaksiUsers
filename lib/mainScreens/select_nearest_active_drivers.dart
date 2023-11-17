import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:user_app/assistans/assistants_methods.dart';
import 'package:user_app/global/global.dart';
import 'package:user_app/utils/constants.dart';

class SelectNearestActiveDriversScreen extends StatefulWidget {
  DatabaseReference? referenceRideRequest;
  SelectNearestActiveDriversScreen({this.referenceRideRequest});

  @override
  State<SelectNearestActiveDriversScreen> createState() => _SelectNearestActiveDriversScreenState();
}

class _SelectNearestActiveDriversScreenState extends State<SelectNearestActiveDriversScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:mainColor,
      appBar:AppBar(
        backgroundColor:Colors.white54,
        title:const Text('Çevirimiçi Taksiler',
        style:TextStyle(fontSize:18) ,),
        leading:IconButton(
          onPressed:() {
            //sürüşü databaseden sil
            widget.referenceRideRequest!.remove();
            Fluttertoast.showToast(msg: 'Taksi isteği iptal edildi');
            SystemNavigator.pop();
          }, 
          icon:Icon(Icons.close,color:mycolor,)),
      ),
      body:ListView.builder(
        itemCount:dList.length,
        itemBuilder: (context, index) {
          return Card(
            color:Colors.grey,
            elevation:3,
            shadowColor:Colors.green,
            margin:EdgeInsets.all(8),
            child:ListTile(
              leading:Padding(
                padding: const EdgeInsets.only(top:2),
                child: Image.asset(
                  "images/"+dList[index]["car_details"]["type"].toString()+".png",
                  width:70,
                ),
              ),
              title:Column(
                mainAxisAlignment:MainAxisAlignment.start,
                children:[
                  Text(
                    dList[index]["name"],
                    style:const TextStyle(
                      fontSize:14,
                      color:Colors.black54
                    ),
                  ),
                  Text(
                    dList[index]["car_details"]["car_model"],
                    style :const TextStyle(
                      fontSize:12,
                      color:Colors.white54
                    ),
                  ),
                  SmoothStarRating(
                    rating:3.5,
                    color:Colors.black,
                    borderColor:Colors.black,
                    allowHalfRating:true,
                    starCount:5,
                    size:15,
                  )
                ],
              ),
              trailing:Column(
                mainAxisAlignment:MainAxisAlignment.center,
                children:[
                 Text(
                    "₺"+AssistanMethods.calculateFareAmountFromOriginToDestination(tripDirectiondetailsInfo!).toString(),
                    style:const TextStyle(
                      fontWeight:FontWeight.bold
                    ),
                  ),
                   SizedBox(height:2,),
                   Text(
                    tripDirectiondetailsInfo!=null?
                    tripDirectiondetailsInfo!.duration_text!:"",
                    style:const TextStyle(
                      fontWeight:FontWeight.bold,
                      color:Colors.black
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}