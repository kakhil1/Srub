import 'package:flutter/material.dart';
import 'package:messagingapp/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 83, 223, 236),
                Color.fromARGB(255, 46, 140, 37),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          padding: EdgeInsets.only(top: 60.0),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.12,
                decoration: BoxDecoration(
                  color: Color.fromARGB(236, 0, 0, 0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Srub is",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Made by ShieldX.\n1st BCA A \n(Deion, Jonathon, Akhilesh) \n\nScan below to share an apk",
                        style: TextStyle(
                          color: Color.fromARGB(255, 47, 255, 203),
                          fontSize: 22.0,
                        ),
                      ),
                      Image.asset(
                        'images/qrcode.png',
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        "https://github.com/kakhil1/Srub",
                        style: TextStyle(
                          color: Color.fromARGB(255, 47, 255, 203),
                          fontSize: 22.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _auth.signOut();
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => About()));
                        },
                        child: Text(
                          "Log Out",
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.w600,
                              fontSize: 22.0),
                        ),

                        /*child: Icon(
                              Icons.exit_to_app_sharp,
                            ),*/
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  bottom: 30,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Home()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 83, 223, 236),
                              Color.fromARGB(255, 46, 140, 37)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "About Srub",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w600,
                          fontSize: 22.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
