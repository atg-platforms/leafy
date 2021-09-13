import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'dart:convert';
import 'account.dart';
import 'farmer.dart';
import 'products.dart';

const primaryColor = Colors.green;

void main() {

  runApp(MaterialApp(
    title: 'Leafy',
    theme: ThemeData(
      primaryColor: primaryColor,
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyApp> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void>? _logged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Welcome'),
          backgroundColor: primaryColor,
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Image.asset('assets/images/leafy-logo.png',
                        height: 100,),
                    ),
                    //Text(
                    //  'Leafy',
                    //  style: TextStyle(
                    //      color: Colors.green,
                    //      fontWeight: FontWeight.w500,
                    //      fontSize: 30),
                    //)
              ),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Sign in',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _usernameController,
                    decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: primaryColor),
                      ),
                      labelText: 'User Name',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: (){
                    //forgot password screen
                  },
                  textColor: Colors.green,
                  child: Text('Forgot Password'),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.green,
                      child: Text('Login'),
                      onPressed: () {
                        setState(() {
                          _logged = login(_usernameController.text,_passwordController.text);
                        });
                      },
                    )),
                Container(
                    child: Row(
                      children: <Widget>[
                        Text('Does not have an account?'),
                        FlatButton(
                          textColor: Colors.green,
                          child: Text(
                            'Create Account',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            //signup screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    )
                ),
                FlatButton(
                  onPressed: (){
                    //forgot password screen
                  },
                  textColor: Colors.grey,
                  child: Text('OR'),
                ),
                Container(
                    child: Row(
                      children: <Widget>[
                        SignInButton(
                          Buttons.Google,
                          onPressed: () {

                          },
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    )),
                Container(
                    child: Row(
                      children: <Widget>[
                        SignInButton(
                          Buttons.FacebookNew,
                          onPressed: () {

                          },
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ))
              ],
            )));
  }

  Future<void> login(String email,String password) async {
    final response = await http.post(
      Uri.parse('https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/auth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': '',
      },
      body: jsonEncode(<String, String>{
        'username': email,
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var acct = jsonDecode(response.body);

      await FlutterSession().set("name", acct['name']);
      await FlutterSession().set("addr", acct['participantAddress']);
      await FlutterSession().set("userID", acct['userID']);
      await FlutterSession().set("participantType", acct['participantType']);
      await FlutterSession().set("email", acct['email']);
      await FlutterSession().set("token", acct['token']);

      if(acct['participantType']=='Farmer'){
        Navigator.push(context,
            MaterialPageRoute(builder: (_context) => Farmer()));
      }else{
        Navigator.push(context,
            MaterialPageRoute(builder: (_context) => Products()));
      }
    } else {
      //return
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
       showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Incorrect username/password'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      //throw Exception('Login Failed');

    }
  }
}