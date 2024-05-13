import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:locket_flutter/components/button.dart";
import "package:locket_flutter/components/text_field.dart";
import "package:locket_flutter/connection/auth/LocketAuth.dart";

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void signIn() async {
    showDialog(
      context: context, 
      builder: (context) => const Center( 
        child: CircularProgressIndicator(),
      )
    );

    try {
      await LocketAuth().signIn(emailTextController.text, passwordTextController.text);

      // pop loading circle
      if(context.mounted){
        Navigator.pop(context);
      };
    } on FirebaseAuthException catch (e) {
      // pop loading circle
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
            const Text("Please log-in to start using LocKet", style: TextStyle(color: Colors.white)),
          
            // email
            const SizedBox(height: 20,),
            CustomTextField(controller: emailTextController, hintText: 'Email', obscureText: false),
          
            // password
            const SizedBox(height: 20,),
            CustomTextField(controller: passwordTextController, hintText: 'Password', obscureText: true),
          
            // sign in
            const SizedBox(height: 20,),
            CustomButton(onTap: signIn, text: "Sign in"),
          
            // go to register
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Not registered?", style: TextStyle(color: Colors.white),),
                const SizedBox(width: 4,),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text("Register now", style: TextStyle(color: Color(0xffffaf36), fontWeight: FontWeight.bold),),
                ),
              ],
            )
          ]),
        ),
      
      )
    );
  }
}