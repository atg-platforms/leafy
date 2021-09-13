import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_session/flutter_session.dart';
import 'dart:async';
import 'dart:convert';
import 'farmer.dart';
import 'main.dart';

const primaryColor = Colors.green;

void main() {

  runApp(MaterialApp(
    title: 'Leafy',
    theme: ThemeData(
      primaryColor: primaryColor,
    ),
    home: Profile(),
  ));
}


class Profile extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Profile> {
  String? userID;
  String? _name;
  String? _participantAddress;
  String? _email;

  @override
  void initState() {
      assignProfile().then((value) {
        //userID = value[0];
        //_name = value[1];
        //_participantAddress = value[2];
        //_email = value[3];
        //print(_participantAddress);
      });

      super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: primaryColor,
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                //backgroundImage: Icons.supervised_user_circle,
              ),
              SizedBox(
                height: 10,
              ),
              new Text(
                  (_name?.isEmpty ?? true) ? "Loading..." : _name.toString(),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                  (_participantAddress?.isEmpty ?? true) ? "Loading..." : _participantAddress.toString(),
              ),
              SizedBox(
                height: 10,
                width: 150,
                child: Divider(
                  thickness: 1,
                  color: Colors.black,
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                color: Colors.grey,
                child: ListTile(
                  leading: Icon(Icons.mail),
                  title: Text(_email.toString()),
                ),
              )
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            logout();
          });
        },
        label: const Text('Logout'),
        icon: const Icon(Icons.logout),
        backgroundColor: primaryColor,
      ),
    );
  }

  Future<List<String>> assignProfile() async {
    //var l = [];
    var xuserID = await FlutterSession().get("userID");
    dynamic xname = await FlutterSession().get("name");
    dynamic xparticipantAddress = await FlutterSession().get("addr");
    dynamic xemail = await FlutterSession().get("email");
    setState(() {
     _name = xname.toString();
     _participantAddress = xparticipantAddress.toString();
     _email = xemail.toString();
    });
    return [];
  }

  Future<void> logout() async {
    await FlutterSession().set("name", "");
    await FlutterSession().set("addr", "");
    await FlutterSession().set("userID", "");
    await FlutterSession().set("participantType", "");
    await FlutterSession().set("email", "");
    await FlutterSession().set("token", "");
    Navigator.push(context, MaterialPageRoute(builder: (_context) => MyApp()));
  }

}