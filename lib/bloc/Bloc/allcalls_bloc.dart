import 'dart:async';
import 'dart:convert';

import 'package:basic_application/Model/ListOfHistory.dart';
import 'package:basic_application/Model/StoredLocation.dart';
import 'package:basic_application/Model/UserInfoStore.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

import '../../main.dart';

part '../Event/allcalls_event.dart';
part '../State/allcalls_state.dart';

class AllcallsBloc extends Bloc<AllcallsEvent, AllcallsState> {
  AllcallsBloc() : super(AllcallsInitial());

  @override
  Stream<AllcallsState> mapEventToState(
    AllcallsEvent event,
  ) async* {
    if (event is getAutoCompleteResponse) {
      yield AllcallsLoading();
      var res = await http.get(Uri.parse(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${event.pattern}&key=AIzaSyC6e6-U093QPQXuv7e_aFFgDPAkZD4nL04"));
      var next = json.decode(res.body);
      yield AllcallsLoadedWithResponse(next);
    }

    if (event is getCurrentLocation) {
      yield AllcallsLoading();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      double lat = position.latitude;
      double long = position.longitude;
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      String name = placemarks[0].street +
          ", " +
          placemarks[0].locality +
          ", " +
          placemarks[0].country;
      StoredLocation.setLat = lat;
      StoredLocation.setLong = long;
      StoredLocation.setCurrentName = name;
      yield AllcallsLoadedWithResponse(name);
    }

    if (event is measureDistance) {
      yield AllcallsLoading();
      List<Location> locations = await locationFromAddress(event.name);
      StoredLocation.setName = event.name;
      double distance = await Geolocator.distanceBetween(
          StoredLocation.currentLat,
          StoredLocation.currentLong,
          locations[0].latitude,
          locations[0].longitude);
      distance = double.parse((distance / 1000).toStringAsFixed(2));

      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_notif',
        'alarm_notif',
        'Channel for Alarm notification',
        icon: 'codex_logo',
        largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
      );

      var iOSPlatformChannelSpecifics = IOSNotificationDetails(
          sound: 'a_long_cold_sting.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true);
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
          0, "Distance", "$distance km", platformChannelSpecifics);
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      CollectionReference users = FirebaseFirestore.instance.collection('data');

      users.add({
        'current_place': StoredLocation.currenthName,
        'searched_place': StoredLocation.searchName,
        'distance': "$distance",
        'uid': UserInfoStore.user.uid,
        'docId': UserInfoStore.user.uid + UserInfoStore.user.uid
      });
      String docId = "";
      await users
          .where('docId',
              isEqualTo: UserInfoStore.user.uid + UserInfoStore.user.uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          docId = doc.id;
        });
      });
      await users.doc(docId).update({'docId': docId});
      yield AllcallsLoadedWithResponse(distance);
    }

    if (event is getListOfHistory) {
      yield AllcallsLoading();
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      CollectionReference users = FirebaseFirestore.instance.collection('data');
      List<String> currentName = [],
          docId = [],
          searchedName = [],
          distance = [];
      var res =
          await users.where('uid', isEqualTo: UserInfoStore.user.uid).get();

      var result = res.docs;
      yield AllcallsLoadedWithResponse(result);
    }

    if (event is removeEntry) {
      yield AllcallsLoading();
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      CollectionReference users = FirebaseFirestore.instance.collection('data');
      await users.doc(event.docId).delete();
      var res =
          await users.where('uid', isEqualTo: UserInfoStore.user.uid).get();
      var result = res.docs;
      yield AllcallsLoadedWithResponse(result);
    }

    if (event is logout) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
          event.context,
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => route == event.context ? true : false);
    }
  }
}
