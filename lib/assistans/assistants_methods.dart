import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_app/assistans/requsets_assistants.dart';
import 'package:user_app/global/global.dart';
import 'package:user_app/global/map_key.dart';
import 'package:user_app/infoHandler/app_info.dart';
import 'package:user_app/models/direction_detail_info.dart';
import 'package:user_app/models/directions.dart';
import 'package:user_app/models/user_%20model.dart';

class AssistanMethods {
  static Future<String> searchAddressForGeoCoordinates(
      Position position, context) async {
    String apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    String humanReadableAdress = "";
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if (requestResponse != 'Error Occured,Failed.') {
      humanReadableAdress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAdress;
      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return humanReadableAdress;
  }

  static void readCurrentOnlineUserInfo() async {
    currenFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currenFirebaseUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        print("name= " + userModelCurrentInfo!.name.toString());
        print("email= " + userModelCurrentInfo!.email.toString());
      }
    });
  }

  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng origionPosition, LatLng destinationPosition) async {
    String urlObtainOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlObtainOriginToDestinationDirectionDetails);
    if (responseDirectionApi == 'Error Occured,Failed.') {
      return null;
    }
    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    directionDetailsInfo.distanse_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distanse_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
    return directionDetailsInfo;
  } //dakika başına yolculuk süresi ücreti

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double timeTraveledFarePerAmonutMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFarePerAmonutKilometer =
        (directionDetailsInfo.duration_value! / 1000) * 0.1;
    double totalFareAmonut = timeTraveledFarePerAmonutMinute +
        distanceTraveledFarePerAmonutKilometer;
    double localCurrencyTotalFare = totalFareAmonut * 19;
    return double.parse(localCurrencyTotalFare.toStringAsFixed(1));
  }
}
