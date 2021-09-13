import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'profile.dart';
import 'farmer.dart';
import 'package:flutter_session/flutter_session.dart';

import 'package:http/http.dart' as http;

const primaryColor = Colors.green;

void main() {

  runApp(MaterialApp(
    title: 'Leafy',
    theme: ThemeData(
      primaryColor: primaryColor,
    ),
    home: OrderPage(),
  ));
}

class OrderPage extends StatefulWidget {

  @override
  _State createState() => _State();
}

class _State extends State<OrderPage> {

  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    fetchData().then((value){
      _orders.addAll(value);
    });
  }

  int _selectedIndex = 1;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Order',
      style: optionStyle,
    ),
    Text(
      'Index 2: Profile',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    if(index==0) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_context) => Farmer()));
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
            title: Text('Order History'),
            backgroundColor: primaryColor,
          ),
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  children: [
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
                                    title: Text('Order ID: ' + _orders[index].id.toString()),
                                    subtitle: Text(_orders[index].date + '   ' + _orders[index].status),
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
                                      ]),
                                ],
                              ),
                            ),
                          );

                        },
                        itemCount: _orders.length,
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
                label: 'Orders',
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
  Future<List<Order>> fetchData() async {
    dynamic token = await FlutterSession().get("token");
    dynamic userID = await FlutterSession().get("userID");
    var orders = List<Order>.empty();
    final response = await http.get(
      Uri.parse('https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/transaction/order/' + userID.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': token,
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var jsonOrder = json.decode(response.body);
      jsonOrder = jsonOrder['data'];
      setState(() {
        orders =  jsonOrder.map<Order>((json) => new Order.fromJson(json)).toList();
      });
      return orders;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create Account.');
    }
  }


}


class Order {
  final String id;
  final String date;
  final String customer;
  final String status;

  Order(this.id, this.date, this.customer, this.status);
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(json['transactionid'].toString(), json['date'], json['customer'], json['status']);
  }

}