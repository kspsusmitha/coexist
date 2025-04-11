import 'package:flutter/material.dart';

class PreviousIncidentsView extends StatelessWidget {
  const PreviousIncidentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.yellow.withOpacity(0.3),
        title: Text("Previous Incidents Reported",style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
      ),
      body: Container(
        color: Colors.yellow.withOpacity(0.3),
        height: double.infinity,
        width: double.infinity,
        child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
         return Container(
           padding: EdgeInsets.all(20),
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20)
            ),
           child: Column(
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   RichText(
                   text: TextSpan(
                   text: "Date: ",
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 15,
                     color: Colors.black
                   ),
                     children: [
                       TextSpan(text: "Oct/20/2024",
                       style: TextStyle(
                         color: Colors.black,
                         fontSize: 15,
                         fontWeight: FontWeight.normal
                       ))
                     ]
                 ),

                 ),

                   RichText(
                     text: TextSpan(
                         text: "Location: ",
                         style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 15,
                             color: Colors.black
                         ),
                         children: [
                           TextSpan(text: "Ekm",
                               style: TextStyle(
                                   color: Colors.black,
                                   fontSize: 15,
                                   fontWeight: FontWeight.normal
                               ))
                         ]
                     ),

                   ),
                 ],
               ),
               SizedBox(
                 height: 10,
               ),
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("Animal Name",style: TextStyle(
                         fontWeight: FontWeight.bold,

                       ),),
                       Container(
                         padding: EdgeInsets.only(left: 10,right: 5,top: 10),
                         decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(10),
                           border: Border.all(
                             color: Colors.black.withOpacity(0.4),
                             width: 1
                           )
                         ),

                         width: 180,
                         height: 70,
                         child: SingleChildScrollView(child: Text("According to the locals, a cow was killed on Saturday in the paddy field close to the forest when it was let off for")),
                       )
                     ],
                   ),
                   SizedBox(
                     width: 50,
                   ),
                   ClipRRect(
                     borderRadius: BorderRadius.circular(10),
                     child: Image.network("https://miro.medium.com/v2/resize:fit:720/1*fMQwyjXGgh2CfYa9fcUcZw.jpeg",
                     height: 80,width: 80,fit: BoxFit.fill,),
                   )
                 ],
               )
             ],
           ),
          );
        }, separatorBuilder: (context, index) {
         return SizedBox(
            height: 15,
          );
        }, itemCount: 20),
      ),
    );
  }
}
