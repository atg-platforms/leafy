import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'profile.dart';
import 'products.dart';
import 'package:flutter_session/flutter_session.dart';

import 'package:http/http.dart' as http;

const primaryColor = Colors.green;

void main() {

  runApp(MaterialApp(
    title: 'Leafy',
    theme: ThemeData(
      primaryColor: primaryColor,
    ),
    home: TransactionPage(),
  ));
}

class TransactionPage extends StatefulWidget {

  @override
  _State createState() => _State();
}

class _State extends State<TransactionPage> {

  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    fetchData().then((value){
      _transactions.addAll(value);
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
      'Index 1: Transaction',
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
          MaterialPageRoute(builder: (_context) => Products()));
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
            title: Text('Transaction History'),
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
                                    title: Text('Transaction ID: ' + _transactions[index].id.toString()),
                                    subtitle: Text(_transactions[index].date + '   ' + _transactions[index].status),
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
                        itemCount: _transactions.length,
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
  Future<List<Transaction>> fetchData() async {
    dynamic token = await FlutterSession().get("token");
    dynamic userID = await FlutterSession().get("userID");
    var transactions = List<Transaction>.empty();
    final response = await http.get(
      Uri.parse('https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/transaction/' + userID.toString()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-api-key': token,
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var jsonTransaction = json.decode(response.body);
      jsonTransaction = jsonTransaction['data'];
      setState(() {
        transactions =  jsonTransaction.map<Transaction>((json) => new Transaction.fromJson(json)).toList();
      });
      return transactions;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create Account.');
    }
  }


}


class Transaction {
  final String id;
  final String date;
  final String farmer;
  final String status;

  Transaction(this.id, this.date, this.farmer, this.status);
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(json['transactionid'].toString(), json['date'], json['farmer'], json['status']);
  }

}