import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:wheeshapp/Pages/AboutMe.dart';
import 'dart:convert';
import 'package:wheeshapp/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'LoginScreen.dart';
import 'AboutMe.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentTab = 0;
  final List<Widget> screens = [MainPage(), AboutMe()];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = MainPage();

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  FirebaseAuth auth = FirebaseAuth.instance;

  int temp = 0;
  String location = '';
  // int woeid;
  String weather = '';
  String abbreviation = '';
  String errorMessage = '';

  Position _currentPosition;
  String _currentAddress;

  String searchApiUrl =
      'https://cuaca.umkt.ac.id/api/cuaca/DigitalForecast-'; // examp : DKIJakarta
  String postUrl = '.xml?format=json';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  initState() {
    super.initState();
    _getCurrentLocation();
  }

  void getSearch(String input, String subAdm) async {
    var searchResult =
        await http.get(Uri.parse(searchApiUrl + input + postUrl));
    var result = json.decode(searchResult.body);
    var res = result['row']['data']['forecast']['area'];
    var resNumArea = findArea(subAdm,
        res); // already fixed, checking if subAdm Kabupaten, change to Kab. .
    // checking error in this line if the resNumArea not find correctly, fix later
    var testTemp =
        res[resNumArea]['parameter'][5]['timerange'][0]['value'][0]['#text'];

    var weatherCheck =
        res[resNumArea]['parameter'][6]['timerange'][0]['value']['#text'];
    var testWeather = weatherCode(int.parse(weatherCheck));

    var testImg = weatherImage(testWeather);

    setState(() {
      temp = int.parse(testTemp).round();
      location = subAdm;
      weather = testWeather;
      abbreviation = testImg;
      errorMessage = '';
    });
  }

  void onTextFieldSubmitted(String input, String subAdm) {
    getSearch(input, subAdm);
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
      String loc = fixUrl(place.administrativeArea);
      onTextFieldSubmitted(loc, place.subAdministrativeArea);
      print(place.administrativeArea);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Colors.blue,
              Colors.blue[300],
              Colors.blue[300],
              Colors.blue[200],
              Colors.white
            ])),
        child: temp == null
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                appBar: AppBar(
                  actions: <Widget>[
                    Column(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'press to \n refresh location ->',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          _getCurrentLocation();
                        },
                        child: Icon(Icons.location_city, size: 36.0),
                      ),
                    )
                  ],
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    "Hello, ${splitEmail(auth.currentUser.email)}\n",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: "Good ${greeting()}",
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                            ],
                          ),
                          style: TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text.rich(
                          TextSpan(
                              text: 'Weather in your location\n',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: '#626262'.toColor()),
                              children: [
                                TextSpan(
                                    text: location,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: '#E53935'.toColor(),
                                        fontSize: 30))
                              ]),
                          style: TextStyle(fontSize: 20, fontFamily: 'Serif'),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: Text(
                            '$weather',
                            style:
                                TextStyle(color: Colors.black, fontSize: 30.0),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: abbreviation == ''
                              ? CircularProgressIndicator()
                              : Image.asset(
                                  'assets/img/' + abbreviation + '.png',
                                  width: 100,
                                ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            temp.toString() + ' °C',
                            style:
                                TextStyle(color: Colors.black, fontSize: 50.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text.rich(
                      TextSpan(
                          text:
                              "Data from BMKG \n(Badan Meteorologi, Klimatologi, dan Geofisika)",
                          style: TextStyle(color: '#626262'.toColor())),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              signOut().then((value) => Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => LoginScreen())));
                            },
                            child: Text('Logout'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                            ),
                          ),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(right: 10.0),
                        ),
                        SizedBox(width: 50,),
                        Container(
                          child: ElevatedButton(
                            onPressed: () {
                              Route route = MaterialPageRoute(
                                  builder: (context) => AboutMe());
                              Navigator.push(context, route);
                            },
                            child: Text('About Me'),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12 && hour > 4) {
    return 'Morning';
  } else if (hour <= 4) {
    return 'Night';
  } else if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

String splitEmail(email) {
  var res = email.split('@');
  return res[0];
}

String fixUrl(input) {
  if (input == 'Daerah Khusus Ibukota Jakarta') {
    input = 'DKIJakarta';
  } else if (input == 'Daerah Istimewa Yogyakarta') {
    input = 'DIYogyakarta';
  }

  String res = input.replaceAll(' ', '');
  return res;
}

int findArea(String adm, var text) {
  int flag = 0;
  var getKab = adm.split(' ');

  if (getKab[0] == 'Kabupaten') {
    adm = 'Kab.';
    for (var i = 1; i < getKab.length; i++) {
      adm += ' ' + getKab[i];
    }
  }

  for (var i = 0; i < text.length; i++) {
    if (adm == text[i]['name'][1]['#text']) {
      flag = i;
    }
  }

  return flag;
}

String weatherCode(int num) {
  switch (num) {
    case 0:
      return "Clear Skies";
      break;
    case 1:
      return "Partly Cloudy";
      break;
    case 2:
      return "Partly Cloudy";
      break;
    case 3:
      return "Mostly Cloudy";
      break;
    case 4:
      return "Overcast";
      break;
    case 5:
      return "Haze";
      break;
    case 10:
      return "Smoke";
      break;
    case 45:
      return "Fog";
      break;
    case 60:
      return "Light Rain";
      break;
    case 61:
      return "Light Rain";
      break;
    case 63:
      return "Heavy Rain";
      break;
    case 80:
      return "Isolated Shower";
      break;
    case 95:
      return "Severe Thunderstorm";
      break;
    case 97:
      return "Severe Thunderstorm";
      break;
    default:
      return "none";
  }
}

String weatherImage(String input) {
  String res = input.replaceAll(' ', '');
  String cond = greeting();
  if (res == 'Fog' ||
      res == 'Haze' ||
      res == 'IsolatedShower' ||
      res == 'PartlyCloudy') {
    if (cond == 'Evening' || cond == 'Night') {
      return res + 'pm';
    } else {
      return res + 'am';
    }
  }
  return res;
}
