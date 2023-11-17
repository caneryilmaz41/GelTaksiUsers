import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_app/assistans/assistants_methods.dart';
import 'package:user_app/assistans/geofire_assistants.dart';
import 'package:user_app/global/global.dart';
import 'package:user_app/infoHandler/app_info.dart';
import 'package:user_app/mainScreens/search_places_screen.dart';
import 'package:user_app/mainScreens/select_nearest_active_drivers.dart';
import 'package:user_app/models/active_nearby_avaliable_drivers.dart';
import 'package:user_app/utils/constants.dart';
import 'package:user_app/widgets/my_drawer.dart';
import 'package:user_app/widgets/progress_dialog.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationHeight = 220;
  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0;
  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circlesSet = {};
  String userName = 'your name';
  String userEmail = 'your email';
  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;
  List<ActiveNearbyAvaliableDrivers> onlineNearByAvailableDriversList = [];
  DatabaseReference? referenceRideRequest;
  blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  checkIfPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAdress =
        await AssistanMethods.searchAddressForGeoCoordinates(
            userCurrentPosition!, context);
    print('senin adres= ' + humanReadableAdress);
    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;
    initilaizeGeoFireListener();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfPermissionAllowed();
  }

  saveRideRequestInformation() {
    //taksi isteğini kaydet
    referenceRideRequest=FirebaseDatabase.instance.ref("Taksi istekleri").push();
    var originLocation=Provider.of<AppInfo>(context,listen:false).userPickUpLocation;
    var destinationLocation=Provider.of<AppInfo>(context,listen:false).userDropOffLocation;
    Map originLocationMap={ 
      "latitude":originLocation!.locationLatitude.toString(),
      "longitude":originLocation.locationLongitude.toString()
    };
    Map destinationLocationMap={ 
      "latitude":destinationLocation!.locationLatitude.toString(),
      "longitude":destinationLocation.locationLongitude.toString()
    };
    Map userInformationMap={
      "origin":originLocationMap,
      "destination":destinationLocationMap,
      "time":DateTime.now().toString(),
      "username":userModelCurrentInfo!.name,
      "userphone":userModelCurrentInfo!.phone,
      "originaddres":originLocation.locationName,
      "destinationaddress":destinationLocation.locationName,
      "driverId":"waiting"
    };
    referenceRideRequest!.set(userInformationMap);
    onlineNearByAvailableDriversList =
        GeofireAssistants.activeNearbyAvaliableDriversList;
    searchNearestOnlineDrivers();
  }

  searchNearestOnlineDrivers() async {
    //yakında taksi yoksa
    if (onlineNearByAvailableDriversList.length == 0) {
      referenceRideRequest!.remove();
      setState(() {
        polyLineSet.clear();
        markerSet.clear();
        circlesSet.clear();
        pLineCoordinatesList.clear();
      });
      Fluttertoast.showToast(msg: 'Yakında müsait taksi yok.');
      Fluttertoast.showToast(msg: 'Daha sonra tekrar deneyin,Uygulam Yeniden Başlatılıyor..');
      Future.delayed(const Duration(milliseconds: 4000), () {
       SystemNavigator.pop();
        
      });

      return;
    }
    //yakında taksi varsa
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
    Navigator.push(context, MaterialPageRoute(builder:(c)=>SelectNearestActiveDriversScreen(referenceRideRequest:referenceRideRequest) ));
  }
  retrieveOnlineDriversInformation(List onlineNearestDriversList)async{
    DatabaseReference ref=FirebaseDatabase.instance.ref().child("drivers");
    for(int i=0;i<onlineNearByAvailableDriversList.length;i++){
       await ref.child(onlineNearestDriversList[i].driverId.toString())
       .once()
       .then((dataSnapshot) {
        var driverKeyInfo=dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
        
       });
    }
  }
  @override
  Widget build(BuildContext context) {
    createActiveNearByDriverIconMarker();
    return Scaffold(
      key: sKey,
      drawer: Theme(
          data: Theme.of(context).copyWith(canvasColor: mainColor),
          child: MyDrawer(name: userName, email: userEmail)),
      body: Stack(
        children: [
          GoogleMap(
            markers: markerSet,
            circles: circlesSet,
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            polylines: polyLineSet,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.normal,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                bottomPaddingOfMap = 265;
              });
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              blackThemeGoogleMap();
              locateUserPosition();
            },
          ),
          Positioned(
            top: 36,
            left: 22,
            child: GestureDetector(
              onTap: () {
                if (openNavigationDrawer) {
                  sKey.currentState!.openDrawer();
                } else {
                  SystemNavigator.pop();
                }
              },
              child: CircleAvatar(
                backgroundColor: mycolor,
                child: Icon(
                  openNavigationDrawer ? Icons.menu : Icons.close,
                  color: mainColor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationHeight,
                decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add_location_alt_outlined,
                            color: mycolor,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nereden?',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              Text(
                                Provider.of<AppInfo>(context)
                                            .userPickUpLocation !=
                                        null
                                    ? Provider.of<AppInfo>(context)
                                            .userPickUpLocation!
                                            .locationName!
                                            .substring(0, 50) +
                                        '...'
                                    : "Geçersiz Addres",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: mycolor,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var responseFromSearchScreen = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => SearchPlacesScreen()));
                          if (responseFromSearchScreen == "obtainedDropoff") {
                            //draw routes-draw polyline
                            setState(() {
                              openNavigationDrawer = false;
                            });
                            await drawPolylineFromOriginToDestination();
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_location_alt_outlined,
                              color: mycolor,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nereye?',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context)
                                              .userDropOffLocation !=
                                          null
                                      ? Provider.of<AppInfo>(context)
                                          .userDropOffLocation!
                                          .locationName!
                                      : 'Gitmek İstedğiniz Yer',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: mycolor,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        child: Text('Taksi İste'),
                        onPressed: () {
                          if (Provider.of<AppInfo>(context, listen: false)
                                  .userDropOffLocation !=
                              null) {
                            saveRideRequestInformation();
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Lütden gitmek istediğniz konumu seçiniz');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: mycolor,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> drawPolylineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);
    showDialog(
      context: context,
      builder: (context) => ProgressDialog(message: 'Lütfen Bekleyin..'),
    );
    var directionDetailsInfo =
        await AssistanMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    setState(() {
      tripDirectiondetailsInfo=directionDetailsInfo;
    });
    Navigator.pop(context);
    print('point"""""""""');
    print(directionDetailsInfo!.e_points!);
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);
    pLineCoordinatesList.clear();
    if (decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: mycolor,
          polylineId: const PolylineId("PolylineID"),
          jointType: JointType.round,
          points: pLineCoordinatesList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);
      polyLineSet.add(polyline);
    });
    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          (LatLngBounds(southwest: destinationLatLng, northeast: originLatLng));
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = (LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, originLatLng.longitude)));
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = (LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast:
              LatLng(originLatLng.latitude, destinationLatLng.longitude)));
    } else {
      boundsLatLng =
          (LatLngBounds(southwest: originLatLng, northeast: destinationLatLng));
    }
    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
    Marker originMarker = Marker(
      markerId: const MarkerId('originID'),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: 'Konum'),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationID'),
      infoWindow:
          InfoWindow(title: destinationPosition.locationName, snippet: 'Hedef'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
    );
    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });
    Circle originCircle = Circle(
        circleId: const CircleId('originID'),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng);
    Circle destinationCircle = Circle(
        circleId: const CircleId('destinationID'),
        fillColor: Colors.red,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatLng);
    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  initilaizeGeoFireListener() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            //herhangi bir sürücü çevrimiçi olarak aktif hale geldiğinde
            ActiveNearbyAvaliableDrivers activeNearbyAvaliableDriver =
                ActiveNearbyAvaliableDrivers();
            activeNearbyAvaliableDriver.locationLatitude = map['latitude'];
            activeNearbyAvaliableDriver.locationLongitude = map['longitude'];
            activeNearbyAvaliableDriver.driverId = map['key'];
            GeofireAssistants.activeNearbyAvaliableDriversList
                .add(activeNearbyAvaliableDriver);
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiveDriversOnUsersMap();
            }

            break;
          //herhangi bir sürücü çevrimiçi görünmediğinde
          case Geofire.onKeyExited:
            GeofireAssistants.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;
          //sürücü hareket ettiğinde -konumu güncelle
          case Geofire.onKeyMoved:
            ActiveNearbyAvaliableDrivers activeNearbyAvaliableDriver =
                ActiveNearbyAvaliableDrivers();
            activeNearbyAvaliableDriver.locationLatitude = map['latitude'];
            activeNearbyAvaliableDriver.locationLongitude = map['longitude'];
            activeNearbyAvaliableDriver.driverId = map['key'];
            GeofireAssistants.updateActiveNearbyAvaliableDriversLocation(
                activeNearbyAvaliableDriver);
            displayActiveDriversOnUsersMap();
            break;
          //çevrimiçi aktif sürücüleri users mapte göster
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();

            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnUsersMap() {
    setState(() {
      markerSet.clear();
      circlesSet.clear();
      Set<Marker> dirversMarkerSet = Set<Marker>();
      for (ActiveNearbyAvaliableDrivers eachDriver
          in GeofireAssistants.activeNearbyAvaliableDriversList) {
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);
        Marker marker = Marker(
            markerId: MarkerId(eachDriver.driverId!),
            position: eachDriverActivePosition,
            icon: activeNearbyIcon!,
            rotation: 360);
        dirversMarkerSet.add(marker);
      }
      setState(() {
        markerSet = dirversMarkerSet;
      });
    });
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "images/taksimarker.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }
}
