import 'package:user_app/models/active_nearby_avaliable_drivers.dart';

class GeofireAssistants{
  static List<ActiveNearbyAvaliableDrivers>activeNearbyAvaliableDriversList=[];
  static void deleteOfflineDriverFromList(String driverId){
    int indexNumber=activeNearbyAvaliableDriversList.indexWhere((element) =>element.driverId==driverId);
    activeNearbyAvaliableDriversList.removeAt(indexNumber);
  }
  static void updateActiveNearbyAvaliableDriversLocation(ActiveNearbyAvaliableDrivers driverWhoMoves){
    int indexNumber=activeNearbyAvaliableDriversList.indexWhere((element) =>element.driverId==driverWhoMoves.driverId);
    activeNearbyAvaliableDriversList[indexNumber].locationLatitude=driverWhoMoves.locationLatitude;
    activeNearbyAvaliableDriversList[indexNumber].locationLongitude=driverWhoMoves.locationLongitude;
  }

}