import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/assistans/requsets_assistants.dart';
import 'package:user_app/global/map_key.dart';
import 'package:user_app/infoHandler/app_info.dart';
import 'package:user_app/models/directions.dart';
import 'package:user_app/models/predicted_places.dart';
import 'package:user_app/utils/constants.dart';
import 'package:user_app/widgets/progress_dialog.dart';

class PlacePredictionTileDesign extends StatelessWidget {
  final PredictedPlaces? predictedPlaces;
  PlacePredictionTileDesign({this.predictedPlaces});
  getPlaceDirectionDetails(String? placeId,context)async{
    showDialog(context: context, builder: (context) => ProgressDialog(
      message:'Settings Up Drof-Off,Please Wait...  ' ,
    ),
    );
    String placeDirectionDetails='https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';
   var responseApi= await RequestAssistant.receiveRequest(placeDirectionDetails); 
   Navigator.pop(context);
   if(responseApi=='Error Occured,Failed.'){
    return;
   }if(responseApi["status"]=="OK"){
    Directions directions=Directions();
    directions.locationName=responseApi["result"]["name"];
    directions.locationId=placeId;
    directions.locationLatitude=responseApi["result"]["geometry"]["location"]["lat"];
    directions.locationLongitude=responseApi["result"]["geometry"]["location"]["lng"];
    Provider.of<AppInfo>(context,listen:false).updateDropOffLocationAddress(directions);
    Navigator.pop(context,"obtainedDropoff");
   
   }
  }
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:() {
      getPlaceDirectionDetails(predictedPlaces!.place_id,context);
      
    }, 
    style:ElevatedButton.styleFrom(
      primary:mycolor
    ),
    child:Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(Icons.add_location,
          color:mainColor,),
          const SizedBox(height: 14,),
          Expanded(child: Column(
            children: [
                const SizedBox(height:8,),
                Text(predictedPlaces!.main_text!,
                overflow:TextOverflow.ellipsis,
                style:TextStyle(
                  fontSize:14,
                  color:mainColor,
                ),
                ),
                const SizedBox(height: 2,),
                Text(predictedPlaces!.secondary_text!,
                overflow:TextOverflow.ellipsis,
                style:const TextStyle(
                  color:Colors.white,
                  fontSize:12
                ),
                ),
                const SizedBox(height: 8,)
    
            ],
          ))
        ],
      ),
    ));
  }
}