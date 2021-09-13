import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_session/flutter_session.dart';
import 'dart:async';
import 'dart:convert';
import 'farmer.dart';

const primaryColor = Colors.green;


void main() {

  runApp(MaterialApp(
    title: 'Leafy',
    theme: ThemeData(
      primaryColor: primaryColor,
    ),
    home: AddProduct(),
  ));
}

class AddProduct extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AddProduct> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController unitCostController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  String? _dropdownvalue;
  var items =  ['Arugula','Romaine','Butterhead','Crisphead'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Product'),
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
                      'Product Details',
                      style: TextStyle(fontSize: 20),
                    )),
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
                      hint: Text('Plant Type'),
                      isExpanded: true,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    controller: unitCostController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Unit Cost',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10,10),
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Quantity',
                    ),
                  ),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.green,
                      child: Text('Create'),
                      onPressed: () {
                        setState(() {
                          createProduct(_dropdownvalue.toString(),descriptionController.text,int.parse(unitCostController.text),int.parse(quantityController.text));
                        });
                      },
                    )),
              ],
            )));
  }

  Future<void> createProduct(String plantType,String description,int unitCost,int quantity) async {
    dynamic userID = await FlutterSession().get("userID");
    dynamic token = await FlutterSession().get("token");
    final response = await http.post(
      Uri.parse('https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/product/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': token,
      },
      body: jsonEncode({
        'farmer': userID,
        'plantType': plantType,
        'description': description,
        'unitCost': unitCost,
        'quantity': quantity
      }),
    );

    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      //return Account.fromJson(jsonDecode(response.body));
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Product created'),
          content: const Text('Product created successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_context) => Farmer())),
              child: const Text('OK'),
            ),
          ],
        ),
      );

    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create Account.');
    }
  }

}