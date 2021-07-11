import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:majorproject_covid19_tracker/loading/splashscreen.dart';
import 'package:majorproject_covid19_tracker/main.dart';
import 'package:majorproject_covid19_tracker/pages/countyPage.dart';
import 'package:majorproject_covid19_tracker/pages/info.dart';
import 'package:majorproject_covid19_tracker/panels/infoPanel.dart';
import 'package:majorproject_covid19_tracker/panels/mosteffectedcountries.dart';
import 'package:majorproject_covid19_tracker/panels/worldwidepanel.dart';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  late Map worldData = fetchWorldWideData();
  bool ss = false;
  bool bb = false;
  bool logged = false;
  fetchWorldWideData() async {
    try {
      http.Response response =
          await http.get(Uri.parse('https://corona.lmao.ninja/v2/all'));
      setState(() {
        worldData = json.decode(response.body);
        ss = true;
      });
    } catch (e) {
      print(e);
    }
  }

  late List countryData = fetchCountryData();
  fetchCountryData() async {
    try {
      http.Response response = await http
          .get(Uri.parse('https://corona.lmao.ninja/v2/countries?sort=cases'));
      setState(() {
        countryData = json.decode(response.body);
        bb = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future fetchData() async {
    fetchWorldWideData();
    fetchCountryData();

    print('fetchData called');
  }

  @override
  void initState() {
    fetchData();
    super.initState();
    this.getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          this.loggedInUser = user;
          this.logged = true;
        });
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !ss
        ? SplashScreen()
        : !bb
            ? SplashScreen()
            : Scaffold(
                appBar: AppBar(
                  centerTitle: false,
                  backgroundColor: Colors.green[700],
                  title: Text(
                    'Covid-19 TRACKER',
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.developer_mode),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              // Retrieve the text the that user has entered by using the
                              // TextEditingController.
                              content: Text(
                                'Thank You For Logging In\n'
                                'You have logged in with ${loggedInUser.email}\n'
                                'Hope you get the required data',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[

                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                body: RefreshIndicator(
                  onRefresh: fetchData,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Worldwide',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CountryPage()));
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.circular(15)),
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Regional',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      fetchWorldWideData() == null
                          ? SplashScreen()
                          : WorldwidePanel(
                              worldData: worldData,
                            ),
                      PieChart(
                        dataMap: {
                          'Confirmed': worldData['cases'].toDouble(),
                          'Active': worldData['active'].toDouble(),
                          'Recovered': worldData['recovered'].toDouble(),
                          'Deaths': worldData['deaths'].toDouble(),
                        },
                        animationDuration: Duration(milliseconds: 800),
                        colorList: [
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.black
                        ],
                        chartValuesOptions: ChartValuesOptions(
                          showChartValuesInPercentage: true,
                          decimalPlaces: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Most affected Countries',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      fetchCountryData() == null
                          ? SplashScreen()
                          : MostAffectedPanel(
                              countryData: countryData,
                            ),
                      InfoPanel(),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(
                          'Logged as ${loggedInUser.email}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Center(
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText('WE ARE'),
                              FadeAnimatedText('WE ARE TOGETHER'),
                              FadeAnimatedText('WE ARE TOGETHER IN THE'),
                              FadeAnimatedText('WE ARE TOGETHER IN THE FIGHT')
                            ],
                            onTap: () {
                              print("Tap Event");
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  )),
                ),
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      SizedBox(
                        height: 90.0,
                        child: DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                          ),
                          child: Center(
                            child: Text(
                              'COVID-19',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Information on covid-19',
                        child: ListTile(
                          title: Text(
                            'INFORMATION',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          leading: Icon(Icons.lightbulb),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InfoPage()));
                          },
                        ),
                      ),
                      Tooltip(
                        message: 'Donate to PM CARES',
                        child: ListTile(
                          leading: Icon(Icons.money),
                          title: Text(
                            'DONATE',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          onTap: () {
                            launch('https://www.pmcares.gov.in/en/');
                          },
                        ),
                      ),
                      Tooltip(
                        message: 'MYTH BUSTERS FROM WHO',
                        child: ListTile(
                          leading: Icon(Icons.list_alt),
                          title: Text(
                            'MYTH BUSTERS',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          onTap: () {
                            launch(
                                'https://www.who.int/emergencies/diseases/novel-coronavirus-2019/advice-for-public/myth-busters');
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(
                          "Log out",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        leading: Icon(Icons.logout),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                // Retrieve the text the that user has entered by using the
                                // TextEditingController.
                                content: Text(
                                  'Are you sure you want to logout',
                                  textAlign: TextAlign.center,
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      _auth.signOut();

                                      Navigator.of(context).pushNamedAndRemoveUntil(StartPage.id, (Route<dynamic> route) => false);
                                      logged =
                                          false; //Implement logout functionality
                                    },
                                    child: Text('Yes'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
  }
}
