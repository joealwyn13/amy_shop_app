import 'package:amy_shop_app/product_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserListings extends StatefulWidget{

  @override
  _UserListings createState() => _UserListings();

}

class _UserListings extends State<UserListings> {

  final Stream<DocumentSnapshot> usersListingStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  @override
  void initState() {
    super.initState();
  }

  void navigateToProductPage(String listingID, String listingName){
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ProductPage(listingID, listingName)
    )
    );
  }

  Future<List<Map<String, dynamic>>> getListingsData(
      List<String> listingIDs) async {
    List<Map<String, dynamic>> listingData = [];

    for (String id in listingIDs) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection(
          'listedItems').doc(id).get();
      listingData.add(snapshot.data() as Map<String, dynamic>);
    }

    return listingData;
  }


  FutureBuilder builderContent(List<String> listingIDs) {
    return FutureBuilder(
      future: getListingsData(listingIDs),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Map<String, dynamic>> data = snapshot.data!;

        return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {

              String listingName = data[index]['name'];
              String listingDesc = data[index]['description'];
              String listingID = data[index]['listingID'];

              return ListTile(
                title: Text(listingName),
                subtitle: Text(listingDesc),
                onTap: () { navigateToProductPage(listingID, listingName); },
              );
            }
        );
      },
    );
  }

  StreamBuilder builder(){
    return StreamBuilder<DocumentSnapshot>(
      stream: usersListingStream,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){

        if(snapshot.hasError){
          return const Center(child: Text('Something went wrong'));
        }

        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }

        if(snapshot.data!['listings'] == null){
          return const Center(child: Text('You have no listings.'));
        }

        List<dynamic> data = snapshot.data!['listings'];

        if(data.isEmpty){
          return const Center(child: Text('You have no listings.'));
        }

        List<String> listingIDs = [];

        for(dynamic d in data){
          listingIDs.add(d);
        }

        return builderContent(listingIDs);
      }
    );
  }

  @override
  Widget build(BuildContext context){
    return builder();
  }

}