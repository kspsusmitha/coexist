import 'package:co_exist/previous_incidents_view.dart';
import 'package:co_exist/report_issue_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'locations.dart';

class ChooseMode extends StatelessWidget {
  const ChooseMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset("assets/images/background.jpg",
            height: MediaQuery.of(context).size.height / 4,
            fit: BoxFit.cover,width: double.infinity,),
          Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.5),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50)
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text("CHOOSE MODE",style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    ),),
                    SizedBox(
                      height: 50,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                maximumSize: Size(double.infinity, 45),
                                  minimumSize: Size(double.infinity, 45),
                                  backgroundColor: Colors.grey.withOpacity(0.5),
                                  side: BorderSide(
                                    width: 2,
                                    color: Colors.black,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  )
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportIssueView(),));
                              }, child: Text("Report")),
                          SizedBox(
                            height: 10,
                          ),
                          TextButton(
                              style: TextButton.styleFrom(
                                  maximumSize: Size(double.infinity, 45),
                                  minimumSize: Size(double.infinity, 45),
                                  backgroundColor: Colors.grey.withOpacity(0.5),
                                  side: BorderSide(
                                    width: 2,
                                    color: Colors.black,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)
                                  )
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Locations(),));
                              }, child: Text("Traveling")),
                          SizedBox(
                            height: 10,
                          ),
                          TextButton(
                              style: TextButton.styleFrom(
                                  maximumSize: Size(double.infinity, 45),
                                  minimumSize: Size(double.infinity, 45),
                                  backgroundColor: Colors.grey.withOpacity(0.5),
                                  side: BorderSide(
                                    width: 2,
                                    color: Colors.black,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)
                                  )
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PreviousIncidentsView(),));
                              }, child: Text("Previous incident")),
                        ],
                      ),
                    ),
                    Image.asset("assets/icons/appIcon.png",height: 150,width: 150,),
                    SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),

                            ),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Colors.grey.withOpacity(0.5),
                          ),
                          onPressed: () {

                          }, child: Row(
                            children: [
                              Icon(CupertinoIcons.location_solid,color: Colors.red,),
                              Text("Help Line"),
                            ],
                          )),

                          TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),

                                ),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.grey.withOpacity(0.5),
                              ),
                              onPressed: () {

                              }, child: Row(
                                children: [
                                  Icon(CupertinoIcons.book,color: Colors.black,),
                                  Text(" Guide"),
                                ],
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
          )
        ],
      ),
    );
  }
}
