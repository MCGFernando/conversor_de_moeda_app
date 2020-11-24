import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json-cors&key=2bf5be55";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber))
      ),
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realctrl = TextEditingController();
  final dolarctrl = TextEditingController();
  final euroctrl = TextEditingController();

  double dolar;
  double euro;

  void _realChange(String text){
    double real = double.parse(text);
    dolarctrl.text = (real/dolar).toStringAsFixed(2);
    euroctrl.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChange(String text){
    double dolar = double.parse(text);
    realctrl.text = (dolar*this.dolar).toStringAsFixed(2);
    euroctrl.text = (dolar*this.dolar/euro).toStringAsFixed(2);
  }
  void _euroChange(String text){
    double euro = double.parse(text);
    realctrl.text = (euro*this.euro).toStringAsFixed(2);
    dolarctrl.text = (euro*this.euro/dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando Dados...",
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text("Erro ao carregar os Dados...",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }else{
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150.0, color: Colors.amber) ,
                      buildTextField("Reais", "R", realctrl, _realChange),
                      Divider(),
                      buildTextField("Dolares", "US", dolarctrl, _dolarChange),
                      Divider(),
                      buildTextField("Euros", "£", euroctrl, _euroChange)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f){
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: "$prefix\$"
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    controller: c,
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

