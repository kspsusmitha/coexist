import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co_exist/firebase_func.dart';
import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<LocationModel> _locations = [];

  List<LocationModel> get locations => _locations;

  // Fetch Locations from Firestore
  Future<void> fetchLocations() async {
    try {
      QuerySnapshot snapshot = await _db.collection('tourist places').get();
      _locations = snapshot.docs.map((doc) =>
              LocationModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners(); // Update UI
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }

  // Toggle isSelected
  Future<void> toggleIsSelected(String location, bool currentValue) async {
    try {
      int index =
          _locations.indexWhere((element) => element.location == location);
      if (index != -1) {
        _locations[index].isSelected = currentValue;
        print(_locations[index].isSelected);
      }

      notifyListeners();

      QuerySnapshot querySnapshot = await _db
          .collection('tourist places')
          .where('location', isEqualTo: location)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;

        await _db.collection('tourist places').doc(docId).update({
          'isSelected': !currentValue,
        });

        // Update local list
        int index = _locations.indexWhere((loc) => loc.location == location);
        if (index != -1) {
          _locations[index] = LocationModel(
            location: _locations[index].location,
            image: _locations[index].image,
            images: _locations[index].images,
            description: _locations[index].description,
            isSelected: !_locations[index].isSelected,
            animals: _locations[index].animals,
          );
        }

        notifyListeners(); // Refresh UI
      }
    } catch (e) {
      print("Error updating isSelected: $e");
    }
  }
}
