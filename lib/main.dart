import 'dart:io';

import 'package:amy_shop_app/loginPage.dart';
import 'package:amy_shop_app/product_page.dart';
import 'package:amy_shop_app/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'SellScreen.dart';
import 'user_listings.dart';

import 'product_page.dart';


late List<CameraDescription> cameras;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(FirebaseInitialize());
}

class FirebaseInitialize extends StatefulWidget {
  const FirebaseInitialize({Key? key}) : super(key: key);

  @override
  _FirebaseInitializeState createState() => _FirebaseInitializeState();
}

class _FirebaseInitializeState extends State<FirebaseInitialize> {
  final Future<FirebaseApp> initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        } else {
          return CircularProgressIndicator();
        }
      }
    );
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amy Shopping App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      // home: MyHomePage(title: 'Shopping Home Page'),
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void navigateToSettingsPage(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }



  @override
  Widget build(BuildContext context) {

    String displayName = FirebaseAuth.instance.currentUser!.displayName!;

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(onPressed: navigateToSettingsPage, icon: const Icon(Icons.more_vert))
            ],
            bottom: TabBar(
              tabs: <Tab>[
                Tab(
                  icon: Icon(Icons.add)
                ),
                Tab(
                  icon: Icon(Icons.sell_outlined)
                ),
                Tab(
                  icon: Icon(Icons.cake)
                )
              ],
            ),
            title: Center(child: Text("Welcome,$displayName. Please stream Taylor Swift :D")),
          ),
          body: TabBarView(
              children: <Widget>[
                BuyScreen(),
                SellScreen(),
                UserListings(),
              ]
          )
        ),
    );
  }
}

class BuyScreen extends StatefulWidget {
  const BuyScreen({Key? key}) : super(key: key);

  @override
  _BuyScreenState createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final Stream<QuerySnapshot> listedItemsStream = FirebaseFirestore.instance.collection('listedItems').snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: listedItemsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong',
            style: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.bold
            )
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Fetching Results',
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold
              )
          );
        } else {
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return ListTile(
                leading: (data.containsKey('images') && data['images'].length > 0) ? Image.network(data['images'][0]) : FlutterLogo(size:50.0),
                title: Text(data['name']),
                onTap: () {
                  // todo: navigate to product_page
                  Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProductPage(data['listingID'], data['name'])
                )
              );
                  // showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return AlertDialog(
                  //         title: const Text('Tapped'),
                  //       );
                  //     }
                  // );
                },
                subtitle: Text(data['description']),
              );
          }).toList(),);
        }
      }
    );
  }
}



class TakePicture extends StatefulWidget {
  const TakePicture({Key? key}) : super(key: key);

  @override
  _TakePictureState createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras.first, ResolutionPreset.max);
    initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: CameraPreview(controller),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await initializeControllerFuture;
            final image = await controller.takePicture();
            final String imagePath = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return Scaffold(
                    body: Image.file(File(image.path)),
                    floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.upload),
                      onPressed: () {
                        Navigator.pop(context,image.path);
                      }
                    ),
                  );
                }
              )
            );
            Navigator.pop(context, imagePath);
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt)
      )
    );
  }
}

class UploadData extends StatefulWidget {
  const UploadData({Key? key, required this.name, required this.desc, required this.price, required this.imagesList}) : super(key: key);

  final String? name;
  final String? desc;
  final String? price;
  final List<String> imagesList;

  @override
  _UploadDataState createState() => _UploadDataState();
}

class _UploadDataState extends State<UploadData> {
  CollectionReference listedItems = FirebaseFirestore.instance.collection('listedItems');
  DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
  String uploadDateTime = DateTime.now().millisecondsSinceEpoch.toString();
  List<String> imagesUrls = [];

  void addItemToUser(String listingID) async{
    DocumentSnapshot snapshot = await userDoc.get();
    List<dynamic> listings = snapshot.get("listings");
    listings.add(listingID);
    await userDoc.update({'listings':listings});
  }

  Future<void> listItem() {

    String listingID = DateTime.now().millisecondsSinceEpoch.toString() + "-"+ FirebaseAuth.instance.currentUser!.uid;

    for (String image in widget.imagesList) {
      File fileToUpload = File(image);
      String ts = DateTime.now().millisecondsSinceEpoch.toString() + "-"+ FirebaseAuth.instance.currentUser!.uid;
      String fileName = "product-" + ts + "png";
      FirebaseStorage.instance.ref().child('products/' + uploadDateTime + '/' + fileName).putFile(fileToUpload).then((taskEvent) {
        if (taskEvent.state == TaskState.success) {
          FirebaseStorage.instance.ref().child("products/" + uploadDateTime + '/' + fileName).getDownloadURL().then((value) {
            print(value);
            imagesUrls.add(value);
          }).catchError((error) {
            print('fail');
            print(error);
          });
        }
      });
    }
    print(imagesUrls);
    return listedItems.doc(listingID).set({
      'name' : widget.name,
      'description' : widget.desc,
      'price' : widget.price,
      'images' : imagesUrls,
      'userID' : FirebaseAuth.instance.currentUser!.uid,
      'listingID' : listingID
    })
    .then((value) async{ addItemToUser(listingID); })
    .catchError((error) => print("Failed to list item: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text("List item"),
      onPressed: listItem,
      // onPressed: () async { addItemToUser("sdf"); },
    );
  }
}

class DisplayImages extends StatefulWidget {
  const DisplayImages({Key? key, required this.imagesList}) : super(key: key);

  final List<String> imagesList;

  @override
  _DisplayImagesState createState() => _DisplayImagesState();
}

class _DisplayImagesState extends State<DisplayImages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Images'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 2/3,
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {
          return Container(
            child: Image.file(File(widget.imagesList[index])),
            constraints: BoxConstraints(
              maxWidth: 100.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            margin: EdgeInsets.all(5.0),
          );
        },
        itemCount: widget.imagesList.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
      )
    );
  }
}

