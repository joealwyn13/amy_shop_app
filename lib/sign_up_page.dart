import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class SignUp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => SignUpState();
}


class SignUpState extends State<SignUp> {

  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _displayName = '';
  String _password = '';
  String _confirmpassword = '';

  bool submitLock = false;

  bool validateForm(){
    // Check the user's input
    // popUpInfo("Validate form function not finised");
    if(_confirmpassword == _password && _password.isNotEmpty && _displayName.isNotEmpty){
      return true;
    }
    popUpInfo("Your form is wrong");
    return false;
  }

  void popUpInfo(String message) async{
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


Future<void> createUserDocument(String uid, String displayName) {
    DocumentReference user = FirebaseFirestore.instance.collection('users').doc(uid);
    return user.set({
      'userID': uid,
      'displayName': displayName,
      'listings': []
    })
    .then( (_){ print("successfully created user document"); } )
    .catchError((error) => print("Failed to update user: $error"));
}

  void onSignUpButtonPressed() async{
    if(submitLock){
      print("submitLock is on");
      return;
    }

    submitLock = true;


    if(validateForm()){
      try{
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
        await userCredential.user!.updateDisplayName(_displayName);
        await createUserDocument(userCredential.user!.uid, _displayName);
        popUpInfo("Registration Successful");

        submitLock = false;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Shopping Home Page')),
              (route) => false,
        );
      } on FirebaseAuthException catch(e){
        if(e.code == 'weak-password'){
          popUpInfo("Weak password");
        }
        else if(e.code == 'email-already-in-use'){
          popUpInfo("email-already-in-use");
        }
        else if(e.code == 'invalidEmail'){
          popUpInfo("invalidEmail");
        }
        else{
          popUpInfo("Unknown Error, try again later");
        }
      }

      submitLock = false;
    }
    else {
      submitLock = false;
      print("invalid form");
    }

  }

  Form SignUpForm(){
    return Form(
        key: _formKey,
        child: Column(
          children: [

            // Email Field
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'username@example.com',
                labelText: 'Email *',
              ),
              onChanged: (String value){ _email = value; },
            ),


            // Display Name Field
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Taylor Swift',
                labelText: 'Display Name *',
              ),
              onChanged: (String value){ _displayName = value; },
            ),


            // Password Field
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Password',
                labelText: 'Password *',
              ),
              obscureText: true,
              onChanged: (String value){ _password = value; },
            ),

            // Password Field
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
                labelText: 'Confirm Password *',
              ),
              obscureText: true,
              onChanged: (String value){ _confirmpassword = value; },
            ),

            // Login Button & SignUp Button
            ElevatedButton(onPressed: onSignUpButtonPressed, child: Text('Register')),

          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Sign Up'),),
        body: SignUpForm()
    );
  }
}