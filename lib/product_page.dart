import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget{

  final String listingID;
  final String listingName;


  const ProductPage(this.listingID, this.listingName, {Key? key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();

}
class _ProductPageState extends State<ProductPage> {
  Future<DocumentSnapshot> getListingData() async {
    DocumentReference listingInfo = FirebaseFirestore.instance.doc('listedItems/${widget.listingID}');
    return await listingInfo.get();
}


  ListView imagesListView(List<dynamic> imageURLs){
    return ListView.builder(
      itemCount: imageURLs.length,
      itemBuilder: (content, index){
        return Image.network(imageURLs[index]);
      }
    );
  }


  Widget listingBody(DocumentSnapshot listingSnapshot){
    List<dynamic> imageURLs = listingSnapshot['images'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            widget.listingName,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize:32,
            ),
          ),

          Text(
            '\$${listingSnapshot['price']}',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const Text(''),

          const Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          Text(listingSnapshot['description']),

          const Text(''),
          //Images Section
          Expanded(child: imagesListView(imageURLs)),

          Center(
            child:
            listingSnapshot['userID'] == FirebaseAuth.instance.currentUser!.uid
                ? ElevatedButton(onPressed: null, child: Text('Remove Listing'))
                : Container()
          ),
        ],
      ),
    );
  }

  FutureBuilder contentBody(){
    return FutureBuilder(
      future: getListingData(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return const Center(child: Text('Something went wrong'));
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }
        return listingBody(snapshot.data);
      }
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listingName),
      ),
      body: contentBody(),
    );
  }
}