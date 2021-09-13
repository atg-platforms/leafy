import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'dart:async';
import 'dart:convert';
import 'product.dart';
import 'profile.dart';
import 'order.dart';


import 'package:http/http.dart' as http;

const primaryColor = Colors.green;

void main() {

  runApp(MaterialApp(
    title: 'Leafy',
    theme: ThemeData(
      primaryColor: primaryColor,
    ),
    home: Farmer(),
  ));
}

class Farmer extends StatefulWidget {

  @override
  _State createState() => _State();
}

class _State extends State<Farmer> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController proofOfIdentityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController shortIntroController = TextEditingController();

  List<Product> _products = [];// List<Product>.empty();
  List<Product> _filteredProducts = [];
  List<Product> _cartList = [];

  @override
  void initState() {
    super.initState();
    fetchData().then((value){
      _products.addAll(value);
      _filteredProducts = _products;
    });
  }

  void _runFilter(String enteredKeyword) {
    _products = _filteredProducts;
    List<Product> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _products;
    } else {
      for(var product in _products){
        if(product.plantType.toLowerCase().contains(enteredKeyword.toLowerCase())) {
          results.add(product);
        }
      }

      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _products = results;
    });
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    if(index==1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_context) => OrderPage()));
    }
    if(index==2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_context) => Profile()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Products',
        theme: ThemeData(
          primarySwatch: primaryColor,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Products'),
            backgroundColor: primaryColor,

          ),
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      onChanged: (value) => _runFilter(value),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Search', suffixIcon: Icon(Icons.search)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child:
                      ListView.builder(
                        itemBuilder: (context,index){
                          return Card(
                            child: Container(
                              //height: 1
                              padding: EdgeInsets.all(10),
                              child:  Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.album),
                                    title: Text(_products[index].plantType),
                                    subtitle: Text('Farmer: ' + _products[index].farmer + '   Location: ' + _products[index].city),
                                    isThreeLine: true,
                                  ),
                                  TextButton(
                                    child: const Text('VIEW DETAILS'),
                                    onPressed: () {
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );

                        },
                        itemCount: _products.length,
                      ),
                    )])),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_context) => AddProduct()));
            },
            child: const Icon(Icons.add),
            backgroundColor: Colors.green,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: primaryColor,
            onTap: _onItemTapped,
          ),
        )
    );
  }
  Future<List<Product>> fetchData() async {
    dynamic userID = await FlutterSession().get("userID");
    dynamic token = await FlutterSession().get("token");

    var products = List<Product>.empty();
    final response = await http.get(
      Uri.parse('https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/product/inventory/' + userID.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': token,
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var jsonProduct = json.decode(response.body);
      jsonProduct = jsonProduct['data'];
      setState(() {
        products =  jsonProduct.map<Product>((json) => new Product.fromJson(json)).toList();
      });
      return products;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create Account.');
    }
  }


}

class Product {
  final String pid;
  final int userID;
  final String farmer;
  final String plantType;
  final int quantity;
  final String city;
  String img;

  Product(this.pid, this.userID, this.farmer, this.plantType, this.quantity, this.city, this.img);
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(json['pid'].toString(), json['userID'], json['farmer'], json['plantType'], json['quantity'], json['city'], json['img']);
  }

}