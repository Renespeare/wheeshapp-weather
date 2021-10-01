import 'package:flutter/material.dart';
import 'RegisterScreen.dart';
import 'MainPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wheeshapp/main.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/img/cloud.png",
                height: 80,
                width: 80,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text.rich(
                TextSpan(
                    text: 'Wheesh\n',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: '#E53935'.toColor()),
                    children: [
                      TextSpan(
                          text: 'weather for you.',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: '#626262'.toColor(),
                              fontSize: 15))
                    ]),
                style: TextStyle(fontSize: 40, fontFamily: 'Serif'),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                "Let's get started",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Email "),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Password"),
              ),
            ),
            // TextButton(onPressed: () {}, child: Text("Forgot Password")),
            SizedBox(height: 40),
            Container(
              height: 50,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                // textColor: Colors.white,
                style: ElevatedButton.styleFrom(
                  primary: Colors.black, // background
                  onPrimary: Colors.white, // foreground
                ),
                child: Text("Login"),
                onPressed: () async {
                  await _firebaseAuth
                      .signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text)
                      .then((value) => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => MainPage())));
                },
              ),
            ),
            Container(
                child: Row(children: <Widget>[
              Text("   Don't have any account?"),
              TextButton(
                  // textColor: Colors.blue,
                  child: Text(
                    "Register",
                    style: TextStyle(fontSize: 17),
                  ),
                  onPressed: () {
                    Route route = MaterialPageRoute(
                        builder: (context) => RegisterScreen());
                    Navigator.push(context, route);
                  })
            ]))
          ],
        ),
      ),
    );
  }
}

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.grey[300],
  primary: Colors.blue[300],
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
  ),
);
