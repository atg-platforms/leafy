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
  String? _balance;

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
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                color: Colors.grey,
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(_name.toString()),
                ),
              ),
              SizedBox(
                height: 2,
              ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.grey,
            child: ListTile(
              leading: Icon(Icons.memory),
              title: Text(_participantAddress.toString()),
            ),
          ),
              SizedBox(
                height: 2,
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                color: Colors.grey,
                child: ListTile(
                  leading: Icon(Icons.money),
                  title: Text('Wallet Balance: LFY ' + _balance.toString()),
                ),
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
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
    var xuserID = await FlutterSession().get("userID");
    dynamic xname = await FlutterSession().get("name");
    dynamic xparticipantAddress = await FlutterSession().get("addr");
    dynamic xemail = await FlutterSession().get("email");
    dynamic token = await FlutterSession().get("token");
    var balance = "";

    final wallet = await http.get(
      Uri.parse(
          'https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/token/balance/' + xparticipantAddress.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': token,
      },
    );

    if (wallet.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var json = jsonDecode(wallet.body);
      balance = json['balance'];
      //return Account.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to checkout.');
    }

    setState(() {
     _name = xname.toString();
     _participantAddress = xparticipantAddress.toString();
     _email = xemail.toString();
     _balance = balance;
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