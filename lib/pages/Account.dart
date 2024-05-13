import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:locket_flutter/components/profile_box.dart";
import 'package:flutter/services.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:geocoding/geocoding.dart';
import "package:locket_flutter/components/toast.dart";
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;


class Account extends StatefulWidget {
  final Function()? signOut;
  const Account({super.key, required this.signOut});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // all users
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  String buttonTextCurrentLocation = "Use current location";

  bool _isButtonDisabled = false;

  // edit
  Future<void> editFieldNumber(String field, String name) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(
          "Edit " + name,
          style: const TextStyle( 
            fontSize: 20
          ),
        ),
        content: TextField( 
          autofocus: true,
          decoration: InputDecoration( 
            hintText: "Enter new ${name}"
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [ 
          // cancel
          TextButton(
            onPressed: () => {
              Navigator.pop(context),
              newValue = ""
            }, 
            child: const Text('Cancel')),

          // save
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue), 
            child: const Text('Save')),
        ],
      )
    );

    // update firestore
    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  Future<void> editField(String field, String name) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(
          "Edit " + name,
          style: const TextStyle( 
            fontSize: 20
          ),
        ),
        content: TextField( 
          autofocus: true,
          decoration: InputDecoration( 
            hintText: "Enter new ${name}"
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [ 
          // cancel
          TextButton(
            onPressed: () => {
              Navigator.pop(context),
              newValue = ""
            }, 
            child: const Text('Cancel')),

          // save
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue), 
            child: const Text('Save')),
        ],
      )
    );

    // update firestore
    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"), 
        // backgroundColor: Colors.blue,
        actions: [
          IconButton(onPressed: widget.signOut, 
          icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>( 
        stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Center(
              child: Column( 
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  const Icon(
                    Icons.person,
                    size: 72
                  ),

                  Text(
                    currentUser.email!,
                    style: const TextStyle( 
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  
                  const SizedBox(height: 20,),

                  ProfileBox(
                    text: userData['username'], 
                    sectionName: 'Name',
                    onPressed: () => editField('username', 'name'),
                    isShowButton: true,
                  ),

                  ProfileBox(
                    text: userData['handphone'], 
                    sectionName: 'Handphone number',
                    onPressed: () => editFieldNumber('handphone', 'handphone number'),
                    isShowButton: true,
                  ),

                  ProfileBox(
                    text: userData['homeLoc'], 
                    sectionName: 'Order location',
                    onPressed: () => editField('homeLoc', 'order location'),
                    isShowButton: false,
                  ),

                  const SizedBox(height: 20,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [ 
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlacePicker(
                                    apiKey: 'AIzaSyCb6frJQNMU4MdfXeYZtwkYrUa4gq00F-M',
                                    onPlacePicked: (result) { 
                                      _setHomeLoc(result.formattedAddress!);
                                      Navigator.of(context).pop();
                                    },
                                    initialPosition: const LatLng(29.146727, 76.464895),
                                    useCurrentLocation: true,
                                    resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                                  ),
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffffaf36),
                          fixedSize: Size(MediaQuery.of(context).size.width * 0.40, 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                        ),
                        child: const Text('Location picker', maxLines: 1, style: TextStyle( 
                          color: Colors.white
                        ),),
                        
                      ),
                      const SizedBox(width: 10,),
                      ElevatedButton(
                        onPressed: _isButtonDisabled ? null : _getCurrentPosition,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffffaf36),
                          fixedSize: Size(MediaQuery.of(context).size.width * 0.45, 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                        ),
                        child: Text(buttonTextCurrentLocation, maxLines: 1, style: const TextStyle( 
                          color: Colors.white
                        ),),
                        
                      ),
                    ],
                  ),

                  const SizedBox(height: 72,)
                ],
              )
            );
          } else if(snapshot.hasError) {
            return Center(
              child: Text("Error ${snapshot.error}"),
            );
          }
          return const Center( 
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<void> _getCurrentPosition() async {
    setState(() {
      _isButtonDisabled = true;
      buttonTextCurrentLocation = "Fetching location";
    });
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _saveLocFromLatLng(position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _saveLocFromLatLng(Position position) async {
  await placemarkFromCoordinates(
          position.latitude, position.longitude)
      .then((List<Placemark> placemarks) {
    Placemark place = placemarks[0];
    usersCollection.doc(currentUser.email).update({"homeLat": position.latitude});
    usersCollection.doc(currentUser.email).update({"homeLong": position.longitude});
    usersCollection.doc(currentUser.email).update({"homeLoc": '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}'});
    setState(() {
      _isButtonDisabled = false;
      buttonTextCurrentLocation = "Use current location";
    });
  }).catchError((e) {
    debugPrint(e);
  });
 }

  Future<void> _setHomeLoc(String location) async
  {
    List<geo.Location> addresses = await 
    locationFromAddress(location);

    var place = addresses.first;
    await usersCollection.doc(currentUser.email).update({"homeLat": place.latitude});
    await usersCollection.doc(currentUser.email).update({"homeLong": place.longitude});
    await usersCollection.doc(currentUser.email).update({"homeLoc": location});
  }


  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showToast(message: 'Location services are disabled. Please enable the services');
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {   
        showToast(message: 'Location permissions are denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      showToast(message: 'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    return true;
  }
}