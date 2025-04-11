import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset("assets/images/background.jpg",
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2,fit: BoxFit.fill,),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.green,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50)
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("C",style: TextStyle(
                        color: Colors.white,
                        fontSize: 30
                      ),),
                      Icon(CupertinoIcons.globe,color: Colors.white,size: 30,),
                      Text("- RXI"),
                      Image.asset("name")
                      
                    ],
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
