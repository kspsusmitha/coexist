import 'package:carousel_slider/carousel_slider.dart';
import 'package:co_exist/firebase_func.dart';
import 'package:flutter/material.dart';

class LocationDetails extends StatelessWidget {
  LocationDetails({super.key, required this.model});
  LocationModel model;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: Stack(
          children: [
            Image(
              image: NetworkImage("${model.image}"),
              height: 350,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            Positioned(
                bottom: 0,
                left: 0,
                top: 220,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Column(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.only(bottom: 15, left: 30, right: 30),
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 5,
                                color: Colors.black.withAlpha(100),
                                // offset: Offset(5, 0),
                                spreadRadius: 5,
                                blurStyle: BlurStyle.normal)
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            model.location,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                          decoration: BoxDecoration(
                              // color: const Color.fromARGB(255, 255, 255, 255),
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withAlpha(180),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        height: 40,
                                        width: 40,
                                        child: Icon(Icons.star,
                                            color: model.isSelected
                                                ? Colors.yellow
                                                : Colors.white))
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  model.description,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                CarouselSlider.builder(itemCount: model.images.length, itemBuilder: (context, index, realIndex) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                      child: Image(image: NetworkImage(model.images[index]),height: 150,fit: BoxFit.fill,));
                                }, options: CarouselOptions(
                                  enlargeCenterPage: true,
                                  autoPlay: true
                                )),

                                ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                          "${model.animals[index].image}",
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.fill,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                         
                                        ),
                                        child: Text("     ${model.animals[index].name}     ",style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                        ),),
                                      )
                                    ],
                                  );
                                }, separatorBuilder: (context, index) {
                                  return SizedBox(height: 20,);
                                }, itemCount: model.animals.length)

                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class $ {}













