import 'package:co_exist/location_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'location_provider.dart';

class Locations extends StatefulWidget {
  @override
  State<Locations> createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: locationProvider.locations.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemBuilder: (context, index) {
                var location = locationProvider.locations[index];

                return InkWell(
                  onTap: () {
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LocationDetails(model: locationProvider.locations[index],),));
                  },
                  child: Container(
                    height: 200,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 5,
                          color: Colors.black.withAlpha(100),
                          offset: Offset(5, 0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        // Shimmer loading effect
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Load network image with FadeInImage
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FadeInImage(
                            placeholder:
                                NetworkImage('https://png.pngtree.com/png-vector/20210604/ourmid/pngtree-gray-network-placeholder-png-image_3416659.jpg',scale: 1), // Add a local placeholder image
                            image: NetworkImage(location.image),
                            fit: BoxFit.fill,
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            onPressed: () {
                              locationProvider.toggleIsSelected(
                                  location.location, location.isSelected);
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(180),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              height: 40,
                              width: 40,
                              child: Icon(
                                location.isSelected
                                    ? Icons.star
                                    : Icons.star,
                                color: location.isSelected ? const Color.fromARGB(255, 241, 241, 1) : Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  // topLeft: Radius.circular(20)
                                  ),
                              color: Colors.white.withAlpha(170),
                            ),
                            alignment: Alignment.center,
                            height: 50,
                            width: 200,
                            child: Text(
                              location.location,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 30);
              },
              itemCount: locationProvider.locations.length,
            ),
    );
  }
}
