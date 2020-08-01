import 'dart:io';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ticket_scanner/scanner.dart';
import 'package:ticket_scanner/ticket.dart';

List<Ticket> _tickets = new List<Ticket>();
List<CameraDescription> _cameras;
Color _statusColor = Colors.white;
TextStyle white20style = TextStyle(fontSize: 20, color: Colors.white);
TextStyle grey20style = TextStyle(fontSize: 20, color: Colors.grey[90]);

MaterialColor jadeColor = MaterialColor(
  0xFF7C0000,
  <int, Color>{
    50: Color(0xFF7C0000),
    100: Color(0xFF7C0000),
    200: Color(0xFF7C0000),
    300: Color(0xFF7C0000),
    400: Color(0xFF7C0000),
    500: Color(0xFF7C0000),
    600: Color(0xFF7C0000),
    700: Color(0xFF7C0000),
    800: Color(0xFF7C0000),
    900: Color(0xFF7C0000),
  },
);



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(MyApp());
}

class Properties{
  static List<Ticket> getTickets(){
    return _tickets;
  }

  static void clearTickets(){
    _tickets = new List<Ticket>();
  }

  static void removeTicket(int index){
    _tickets.removeAt(index);
  }

  static Color getStatusColor(){
    return _statusColor;
  }

  static void setStatusColor(Color color){
    _statusColor = color;
  }

  static List<CameraDescription> getCameras(){
    return _cameras;
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Scanner',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: jadeColor,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
//      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  double _getPaidTotal() {
    double sum = 0;
    for (Ticket ticket in _tickets) {
      if (ticket.hasPaid()) {
        sum += ticket.getTotalMinusTips();
      }
    }
    return sum;
  }

  double _getUnpaidTotal() {
    double sum = 0;
    for (Ticket ticket in _tickets) {
      if (!ticket.hasPaid()) {
        sum += ticket.getTotalMinusTips();
      }
    }
    return sum;
  }

  double _getTipsTotal() {
    double sum = 0;
    for (Ticket ticket in _tickets) {
      sum += ticket.getTips();
    }
    return sum;
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket Scanner'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                height: 100,
                child: FlatButton(
                  color: Color.fromARGB(255,150,35,36),
                  child: new Text('Start Scanning', style: white20style),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OcrPage(notifyParent: refresh)),
                    );
                    _statusColor = Colors.white;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                height: 100,
                child: FlatButton(
                  color: Color.fromARGB(255,150,35,36),
                  child: new Text('View Tickets', style: white20style),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TicketPage(notifyParent: refresh)),
                    );
                    _statusColor = Colors.white;
                  },
                ),
              ),
            ),
            Divider(height: 20),
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.green,
                child: new Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: new Text("Paid Total (excl. tips):",
                              style: white20style),
                        ),
                        flex: 100),
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: new Text(_getPaidTotal().toStringAsFixed(2),
                              style: white20style),
                        ),
                        flex: 0),
                  ],
                ),
              ),
            ),
            Divider(height: 20),
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.red,
                child: new Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: new Text("Unpaid Total (excl. tips):",
                              style: white20style),
                        ),
                        flex: 100),
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: new Text(_getUnpaidTotal().toStringAsFixed(2),
                              style: white20style),
                        ),
                        flex: 0),
                  ],
                ),
              ),
            ),
            Divider(height: 20),
            Center(
              child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.blue,
                  child: new Row(
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: new Text("Tips:",
                                style: white20style),
                          ),
                          flex: 100),
                      Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: new Text(_getTipsTotal().toStringAsFixed(2),
                                style: white20style),
                          ),
                          flex: 0),
                    ],
                  ),
              ),
            ),
            Divider(height: 20),
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.grey,
                child: new Row(
                  children: <Widget>[
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: new Text("Grand Total:",
                              style: white20style),
                        ),
                        flex: 100),
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: new Text((_getPaidTotal() + _getUnpaidTotal() + _getTipsTotal()).toStringAsFixed(2),
                              style: white20style),
                        ),
                        flex: 0),
                  ],
                ),
              ),
            ),
            Divider(height: 20),
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.black54,
                child: Text("Tickets: " + _tickets.length.toString(),
                    style: white20style),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


