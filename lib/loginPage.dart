import 'package:amy_shop_app/main.dart';
import 'package:amy_shop_app/sign_up_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{

  @override
  _LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage>{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final emailTextFieldController = TextEditingController();
  final passwordTextFieldController = TextEditingController();


  void showSnackBar(String message){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? validateEmail(String? email){
    RegExp emailRegex = RegExp(r'\w+@\w+\.\w+');
    if(email == null || email.isEmpty || !emailRegex.hasMatch(email)){
      return "Please enter a valid email.";
    }
    return null;
  }


  String? validatePassword(String? password){
    if(password == null || password.isEmpty){
      return "Please enter a password.";
    }
    return null;
  }


  bool signInLock = false;

  void loginButton() async{
    if(signInLock){
      showSnackBar("Signing you in Please Wait...");
      return;
    }

    signInLock = true;

    if(_formKey.currentState!.validate()){
      try{
        await FirebaseAuth.instance.signInWithEmailAndPassword(email:emailTextFieldController.text, password: passwordTextFieldController.text);
        showSnackBar("Signing you in Please Wait...");
        signInLock = false;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Shopping Home Page')),
              (route) => false,
        );
      }
      catch (e){
        signInLock = false;
        showSnackBar("Could not sign in with your credentials");
      }

    }
    else {
      showSnackBar("Your form is invalid");
    }
    signInLock = false;
  }


  void signupButton(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUp()),
    );
  }

  Form form(){
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          children: [

            const Text(
                'Shop App',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
            ),

            // Email Text Form Field
            TextFormField(
              controller: emailTextFieldController,
              validator: validateEmail,
              decoration: const InputDecoration(
                hintText: "username@example.com",
                labelText: "Email",
              ),
            ),

            // Password Text Form Field
            TextFormField(
              controller: passwordTextFieldController,
              validator: validatePassword,
              decoration: const InputDecoration(
                hintText: "Password",
                labelText: "Password",
              ),
              obscureText: true,
            ),
            ElevatedButton(onPressed: loginButton, child: Text("Login")),
            ElevatedButton(onPressed: signupButton, child: Text("Sign Up")),

          ],
        )
      )
    );
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SingleChildScrollView(
        child: form(),
      ),
    );
  }
}