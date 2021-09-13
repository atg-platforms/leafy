import 'package:flutter/material.dart';
import 'products.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_session/flutter_session.dart';

class Cart extends StatefulWidget {
  final List<Product> _cart;

  Cart(this._cart);

  @override
  _CartState createState() => _CartState(this._cart);
}

class _CartState extends State<Cart> {
  _CartState(this._cart);

  List<Product> _cart;

  String? _dropdownvalue;
  var items =  ['Token','Others'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body:Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            children: [
        Expanded(
        child: ListView.builder(
          itemCount: _cart.length,
          itemBuilder: (context, index) {
            var item = _cart[index];
            return Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: Card(
                elevation: 4.0,
                child: Column(
                    children: <Widget>[
                ListTile(
                  leading: Icon(Icons.album),
                  title: Text(_cart[index].plantType),
                  subtitle: Text('Farmer: ' + _cart[index].farmer + '   Location: ' + _cart[index].city),
                  trailing: GestureDetector(
                      child: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                      ),
                      onTap: () {
                        setState(() {
                          _cart.remove(item);
                        });
                      }),
                  isThreeLine: true,
                ),
              ])
              ),
            );
          },
          )
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
                    hint: Text('Payment Option'),
                    isExpanded: true,
                  ),
                ),
              ),
              SizedBox(
                height: 80,
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            checkOut(_cart);
          });
        },
        label: const Text('Checkout'),
        icon: const Icon(Icons.check_outlined),
        backgroundColor: primaryColor,
      ),
    );
  }

  Future<void> checkOut(List<Product> cart) async {
    dynamic userID = await FlutterSession().get("userID");
    dynamic token = await FlutterSession().get("token");
    dynamic consumer = await FlutterSession().get("addr");
    int total = 0;
    var faddr;
    for(var item in cart) {
      final response = await http.post(
        Uri.parse(
            'https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/transaction/checkout'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-api-key': token,
        },
        body: jsonEncode({
          'consumerID': userID,
          'farmerID': item.userID,
          'plantType': item.plantType,
          'quantity': 1
        }),
      );

      if (response.statusCode == 201) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        //return Account.fromJson(jsonDecode(response.body));
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        throw Exception('Failed to checkout.');
      }

      total = item.unitCost;
      if (_dropdownvalue == 'Token') {
        // Get address of farmer
        final farmer = await http.get(
          Uri.parse(
              'https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/account/' + item.userID.toString()),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-api-key': token,
          },
        );

        if (farmer.statusCode == 200) {
          // If the server did return a 201 CREATED response,
          // then parse the JSON.
          var json = jsonDecode(farmer.body);
          faddr = json['participantAddress'];
          //return Account.fromJson(jsonDecode(response.body));
        } else {
          // If the server did not return a 201 CREATED response,
          // then throw an exception.
          throw Exception('Failed to checkout.');
        }


        final transfer = await http.post(
          Uri.parse(
              'https://bgmcwrffp9.execute-api.ap-southeast-1.amazonaws.com/latest/token/transfer'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-api-key': token,
          },
          body: jsonEncode({
            'sender': consumer,
            'receiver': faddr,
            'quantity': 1
          }),
        );

        if (transfer.statusCode == 200) {
          // If the server did return a 201 CREATED response,
          // then parse the JSON.
          //return Account.fromJson(jsonDecode(response.body));
        } else {
          // If the server did not return a 201 CREATED response,
          // then throw an exception.
          throw Exception('Failed to checkout.');
        }
      }
    }

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Checkout'),
        content: const Text('Checkout successful.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_context) => Products())),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }



}


