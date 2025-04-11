import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_func.dart';

// class FirebaseFunc {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // Fetch Data as a Stream
//   // Stream<List<LocationModel>> getTouristPlaces() {
//   //   return _db.collection('tourist places').snapshots().map((snapshot) =>
//   //       snapshot.docs.map((doc) => LocationModel.fromFirestore(doc.data())).toList()
//   //   );
//   // }
//   // Future<List<LocationModel>> getPlaces() async {
//   //   try {
//   //     QuerySnapshot snapshot = await _db.collection('tourist places').get();
//   //
//   //     return snapshot.docs.map((doc) =>
//   //         LocationModel.fromFirestore(doc.data() as Map<String, dynamic>)
//   //     ).toList();
//   //   } catch (e) {
//   //     print("Error fetching places: $e");
//   //     return [];
//   //   }
//   // }


//   Future<List<LocationModel>> getLocations() async {
    
//     try {
//       QuerySnapshot snapshot = await _db.collection('tourist places').get();
//       final value = snapshot.docs.map((doc) => LocationModel.fromFirestore(doc.data() as Map<String,dynamic>)).toList();
//       print("=======>=>=>>>>$value");
//       return value;
//     } catch (e) {
//       print("Error fetching locations: $e");
//       return [];
//     }
//   }

// Future<void> toggleIsSelected(String location, bool currentValue) async {
//   try {
//     // Find document where location matches
//     QuerySnapshot querySnapshot = await _db
//         .collection('tourist places')
//         .where('location', isEqualTo: location)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       String docId = querySnapshot.docs.first.id; // Get document ID

//       // Update Firestore document
//       await _db.collection('tourist places').doc(docId).update({
//         'isSelected': !currentValue, // Toggle value
//       });

//       print("Updated successfully: $docId");
//     } else {
//       print("No matching document found for location: $location");
//     }
//   } catch (e) {
//     print("Error updating isSelected: $e");
//   }
// }






// }

// Model Class for Tourist Places
// class LocationModel {
//   final String location;
//   final String image;
//   final String description;
//   final bool isSelected;
//   final List<String> images;

//   LocationModel({
//     required this.images,
//     required this.location,
//     required this.image,
//     required this.description,
//     required this.isSelected
//   });

//   // Convert Firestore Document to LocationModel
//   factory LocationModel.fromFirestore(Map<String, dynamic> data) {
//     return LocationModel(
//       location: data['location'] ?? '',
//       image: data['image'] ?? '',
//       description: data['description'] ?? '',
//       isSelected: data['isSelected'] ?? false,
//        images: data["images"] ?? []
//     );
//   }
// }

class LocationModel {
   String location;
   String image;
   List<String> images; // Add this
   String description;
   bool isSelected;
   List<Animals> animals;

  LocationModel({
    required this.location,
    required this.image,
    required this.images, // Add this
    required this.description,
    required this.isSelected,
    required this.animals
  });

  // Convert Firestore Document to LocationModel
  factory LocationModel.fromFirestore(Map<String, dynamic> data) {
    print("======:::===>>>>> ${data["animals"]}");
    return LocationModel(
      location: data['location'] ?? '',
      image: data['image'] ?? '',
      images: List<String>.from(data['images'] ?? []), 
      description: data['description'] ?? '',
      isSelected: data['isSelected'] ?? false,
      animals: (data["animals"] as List<dynamic>? ?? [])
          .map((animal) => Animals.fromFirestore(animal))
          .toList(),
    );
  }
}
class Animals {
  String name;
  String image;

  Animals({
    required this.name,
    required this.image
  });

  factory Animals.fromFirestore(Map<String, dynamic> data) {
    return Animals(
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }
}