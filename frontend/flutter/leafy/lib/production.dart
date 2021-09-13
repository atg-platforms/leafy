import 'package:flutter/material.dart';

const primaryColor = Colors.green;

void main() {

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primaryColor: primaryColor,
    ),
    home: Production(),
  ));
}

class Production extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Production> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController proofOfIdentityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController shortIntroController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Production'),
          backgroundColor: primaryColor,
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
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
                      'Production Details',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: primaryColor),
                      ),
                      labelText: 'Capacity',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Date Planted',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Expected Harvest Date',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10,0),
                  child: TextField(
                    controller: contactNoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Plant Status',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: contactNoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Photo',
                    ),
                  ),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.green,
                      child: Text('Submit'),
                      onPressed: () {
                        print(nameController.text);
                        //print(passwordController.text);
                      },
                    )),
              ],
            )));
  }
}