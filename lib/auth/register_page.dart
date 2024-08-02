import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locket_flutter/components/button.dart';
import 'package:locket_flutter/components/text_field.dart';
import 'package:locket_flutter/connection/auth/LocketAuth.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  void signUp() async {
    showDialog(
      context: context, 
      builder: (context) => const Center( 
        child: CircularProgressIndicator(),
      )
    );

    if(passwordTextController.text != confirmPasswordTextController.text) {
      Navigator.pop(context);
      displayMessage("Password dont match");
      return;
    }

    try {
      // try register
      LocketAuth().signUp(emailTextController.text, passwordTextController.text);

      if(context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog( 
        title: Text(message),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff211a2c),
      body: Center(child: 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            //logo
            const Image(
              image: AssetImage(
                "assets/logo.png"
              ),
              // height: 100,
            ),
          
            // welcome back
            const SizedBox(height: 20,),
            const Text("Register to start using LocKet", style: TextStyle(color: Colors.white),),
          
            // email
            const SizedBox(height: 20,),
            CustomTextField(controller: emailTextController, hintText: 'Email', obscureText: false),
          
            // password
            const SizedBox(height: 20,),
            CustomTextField(controller: passwordTextController, hintText: 'Password', obscureText: true),

            // confirm password
            const SizedBox(height: 20,),
            CustomTextField(controller: confirmPasswordTextController, hintText: 'Confirm password', obscureText: true),
          
            // sign in
            const SizedBox(height: 20,),
            CustomButton(onTap: signUp, text: "Sign Up"),
          
            // go to register
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already registered?", style: TextStyle(color: Colors.white),),
                const SizedBox(width: 4,),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text("Login here", style: TextStyle(color: Color(0xffffaf36), fontWeight: FontWeight.bold),),
                ),

              ],
            )
          ]),
        ),
      
      )
    );
  }
}