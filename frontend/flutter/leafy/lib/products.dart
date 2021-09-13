import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'cart.dart';
import 'profile.dart';
import 'transaction.dart';
import 'package:flutter_session/flutter_session.dart';

import 'package:http/http.dart' as http;

const primaryColor = Colors.green;

void main() {

  runApp(MaterialApp(
    title: 'Leafy',
    theme: ThemeData(
      primaryColor: primaryColor,
    ),
    home: Products(),
  ));
}

class Products extends StatefulWidget {

  @override
  _State createState() => _State();
}

class _State extends State<Products> {
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
      // if the search field is empty or only contains white-space, we'll display data
      results = _products;
    } else {
      for(var product in _products){
        // we use the toLowerCase() method to make it case-insensitive
        if(product.plantType.toLowerCase().contains(enteredKeyword.toLowerCase()) || product.city.toLowerCase().contains(enteredKeyword.toLowerCase())) {
          results.add(product);
        }
      }
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
      'Index 1: Transaction',
      style: optionStyle,
    ),
    Text(
      'Index 2: Profile',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    if(index==1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_context) => TransactionPage()));
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
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0),
              child: GestureDetector(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Icon(
                      Icons.shopping_cart,
                      size: 36.0,
                    ),
                    if (_cartList.length > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: CircleAvatar(
                          radius: 8.0,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          child: Text(
                            _cartList.length.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  if (_cartList.isNotEmpty)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Cart(_cartList),
                      ),
                    );
                },
              ),
            )
          ],
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
                //padding: EdgeInsets.all(10),
                child:  Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.album),
                      title: Text(_products[index].plantType),
                      subtitle: Text(_products[index].city + '   Php ' + _products[index].unitCost.toString()),
                      //isThreeLine: true,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    TextButton(
                      child: const Text('VIEW DETAILS'),
                      onPressed: () {

                      },
                    ),const SizedBox(width: 8),
                  TextButton(
                    child: const Text('ADD TO CART'),
                    onPressed: () {
                      setState(() {
                        if (_cartList.contains(_products[index]))
                          _cartList.remove(_products[index]);
                        else
                          _cartList.add(_products[index]);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ]),
                  ],
                ),
              ),
            );

          },
          itemCount: _products.length,
        ),
    )
                ]
                )),
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
    dynamic token = await FlutterSession().get("token");
    var products = List<Product>.empty();
    final response = await http.get(
      Uri.parse('https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/product'),
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
  final int unitCost;
  final String city;
  String img;

  Product(this.pid, this.userID, this.farmer, this.plantType, this.quantity, this.unitCost, this.city, this.img);
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(json['pid'].toString(), json['userID'], json['farmer'], json['plantType'], json['quantity'], json['unitcost'], json['city'], json['img']);
  }

}