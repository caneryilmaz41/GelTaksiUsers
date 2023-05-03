

import 'package:flutter/material.dart';
import 'package:user_app/assistans/requsets_assistants.dart';
import 'package:user_app/global/map_key.dart';
import 'package:user_app/models/predicted_places.dart';
import 'package:user_app/utils/constants.dart';
import 'package:user_app/widgets/place_predicted_tile.dart';

class SearchPlacesScreen extends StatefulWidget {


  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredictedPlaces>placesPredictedList=[];
  void findPlaceAutoCompleteSearch(String inputText)async{
     if(inputText.length>1){
      String urlAutoCompleteSearch="https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:TR"; 
     var responseAutoCompleteSearch= await RequestAssistant.receiveRequest(urlAutoCompleteSearch);
      if(responseAutoCompleteSearch=='Error Occured,Failed.'){
        return;
      }
      if(responseAutoCompleteSearch["status"]=="OK"){
       var placesPredictions= responseAutoCompleteSearch["predictions"];
      var placesPredictionsList= (placesPredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();
      setState(() {
        placesPredictedList=placesPredictionsList;
      });
      }
     }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:mainColor,
      body:Column(
        children: [
          //serach place ui
          Container(
            height:180,
            decoration:BoxDecoration(
               color:mainColor,
               boxShadow: [
                BoxShadow(
                  color: mycolor,
                  blurRadius:50,
                  spreadRadius:5,
                  offset:Offset(0.7,0.7)
                )
               ]
            ),
            child:Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                 const SizedBox(height: 35,),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios,
                        color: mycolor,),
                      ),
                      Center(child:Text('Konum Seçiniz',style:TextStyle(
                        color:Colors.white,fontSize:20,fontWeight:FontWeight.bold
                      ),),)
                    ],
                  ),
                  const SizedBox(height: 25,),
                  Row(
                    children: [
                      Icon(Icons.adjust_sharp,color:Colors.grey,),
                       SizedBox(height: 16,),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged:(valueTyped) {
                              findPlaceAutoCompleteSearch(valueTyped);
                            },
                            decoration:const InputDecoration(
                              hintText:'Ara...',
                              fillColor:Colors.white54,
                              filled:true,
                              border:InputBorder.none,
                              contentPadding:EdgeInsets.only(
                                left:11,
                                top:8,
                                bottom:8
                              )
                                            
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          //display place predictions result
          (placesPredictedList.length>0)?Expanded(
            child:ListView.separated(
              physics:ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return PlacePredictionTileDesign(
                  predictedPlaces: placesPredictedList[index],
                );
              }, 
              separatorBuilder:(context, index) {
               return Divider(
                  height:1,
                  color:mainColor,
                  thickness:1,
                );
              }, 
              itemCount: placesPredictedList.length ))
          
          :Container(),
        ],
      ),
    );
  }
}