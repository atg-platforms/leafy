import 'dart:async';
import 'dart:convert';
import 'main.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_session/flutter_session.dart';

const primaryColor = Colors.green;

Future<Account> createAccount(String email,String password,String name,String? participantType,String city) async {
  dynamic token = await FlutterSession().get("token");
  final response = await http.post(
    Uri.parse('https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/account/create'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'x-api-key': token,
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
      'name': name,
      'participantType': participantType.toString(),
      'city': city
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Account.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create Account.');
  }
}

class Account {
  final String email;
  final String name;
  final String participantType;
  final String city;
  final String participantAddress;
  final int userID;
  String? message;

  Account({required this.email, required this.name, required this.participantType, required this.city, required this.participantAddress, required this.userID, this.message});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      email: json['email'],
      name: json['name'],
      participantType: json['participantType'],
      city: json['city'],
      participantAddress: json['participantAddress'],
      userID: json['userID'],
      message: json['message'],
    );
  }
}

void main() {
  runApp(const SignUp());
}

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  Future<Account>? _futureAccount;

  String? _dropdownvalue;
  var items =  ['Consumer','Farmer'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leafy',
      theme: ThemeData(
        primarySwatch: primaryColor,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Account'),
          iconTheme: IconThemeData(
            color: primaryColor,
          ),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: (_futureAccount == null) ? buildColumn() : buildFutureBuilder()),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Text(
              'Leafy',
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: 30),
            )),
        Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Text(
              'Account Details',
              style: TextStyle(fontSize: 20),
            )),
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: TextField(
            controller: _emailController,
            decoration: new InputDecoration(
              border: new OutlineInputBorder(
                borderSide: new BorderSide(color: primaryColor),
              ),
              labelText: 'Email',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: TextField(
            controller: _cpasswordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Confirm Password',
            ),
            obscureText: true,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: ButtonTheme(
            alignedDropdown: true,
             child: DropdownButtonFormField(
            value: _dropdownvalue,
              decoration: const InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(0, 20, 10, 20),
              ),
            icon: Icon(Icons.keyboard_arrow_down),
            items:items.map((String items) {
              return DropdownMenuItem(
                  value: items,
                  child: Text(items)
              );
            }
            ).toList(),
            onChanged: (String? newValue){
              setState(() {
                _dropdownvalue = newValue;
              });
            },
            hint: Text('Select Account Type'),
            isExpanded: true,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: TextField(
            controller: _cityController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'City',
            ),
          ),
        ),
        Container(
            height: 50,
            padding: EdgeInsets.all(0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _futureAccount = createAccount(_emailController.text,_passwordController.text,_nameController.text,_dropdownvalue,_cityController.text);
                });
              },
              child: const Text('Create'),
            )),
      ],
    );
  }

  FutureBuilder<Account> buildFutureBuilder() {
    return FutureBuilder<Account>(
      future: _futureAccount,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Center(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text(snapshot.data!.name),
                    subtitle: Text(snapshot.data!.participantAddress),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      //TextButton(
                      //  child: const Text('BUY TICKETS'),
                      //  onPressed: () {/* ... */},
                      //),
                      const SizedBox(width: 8),
                      TextButton(
                        child: const Text('PROCEED TO LOGIN'),
                        onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                        );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          );
          //return Text(snapshot.data!.participantAddress);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}