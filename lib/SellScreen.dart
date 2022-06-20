import 'package:flutter/material.dart';

import 'main.dart';
class SellScreen extends StatefulWidget {
  const SellScreen({Key? key}) : super(key: key);

  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  String? itemName;
  String? itemDesc;
  String? itemPrice;
  List<String> images = [];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                  child: Text("sell", style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold)
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.black,
                          width: 8
                      )
                  ),
                  margin: const EdgeInsets.all(20.0)
              ),

              Container(
                child: Row(
                    children: <Widget>[
                      Icon(Icons.new_label),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: 'Item Name'
                          ),
                          onChanged: (value) => itemName = value,
                        ),
                      )

                    ]
                ),
                width: 250.0,
              ),

              Container(
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.description),
                        Expanded(
                          child: TextField(
                              decoration: InputDecoration(
                                  hintText: 'Item Description'
                              ),
                              onChanged: (value) => itemDesc = value,
                              maxLines: 10
                          ),
                        )

                      ]
                  ),
                  width: 250.0,
                  margin: const EdgeInsets.all(20.0)
              ),

              Container(
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.price_change),
                        Expanded(
                          child: TextField(
                              decoration: InputDecoration(
                                  hintText: 'Item Price'
                              ),
                              onChanged: (value) => itemPrice = value,
                              keyboardType: TextInputType.number
                          ),
                        )

                      ]
                  ),
                  width: 250.0,
                  margin: const EdgeInsets.all(20.0)
              ),

              ElevatedButton(
                child: Container(
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.photo_camera),
                        Text('Camera')
                      ]
                  ),
                  height: 50.0,
                  width: 200.0,
                  margin: const EdgeInsets.all(20.0),
                ),
                onPressed: () async {
                  final String newImage = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TakePicture())
                  );
                  setState(() {
                    images.add(newImage);
                  });
                },
              ),
              SizedBox(
                height: 5.0,
              ),
              ElevatedButton(
                child: Container(
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.image),
                        Text('Images')
                      ]
                  ),
                  height: 50.0,
                  width: 200.0,
                  margin: const EdgeInsets.all(20.0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisplayImages(imagesList: images)),
                  );
                },
              ),

              SizedBox(
                height: 5.0,
              ),

              ElevatedButton(
                child: Container(
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.upload),
                        Text('Upload')
                      ]
                  ),
                  height: 50.0,
                  width: 200.0,
                  margin: const EdgeInsets.all(20.0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder:(context) => UploadData(name: itemName, desc: itemDesc, price: itemPrice, imagesList: images)),
                  );
                },
              )
            ],
          ),
        )
    );
  }
}