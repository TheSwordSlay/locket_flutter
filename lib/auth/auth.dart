import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:locket_flutter/auth/login_or_register.dart";
import "package:locket_flutter/connection/auth/LocketAuth.dart";
import "package:locket_flutter/pages/CashierPage.dart";
import "package:locket_flutter/pages/Homepage.dart";

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: LocketAuth().getAuthState(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            final currentUser = FirebaseAuth.instance.currentUser!;
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Users")
                    .doc(currentUser.email)
                    .snapshots(),
                builder: (context, snapshots) {
                  if (snapshots.data != null) {
                    final userDatas =
                        snapshots.data!.data() as Map<String, dynamic>;
                    if (userDatas['isCashier']) {
                      return const CashierPage();
                    } else {
                      return const Homepage();
                    }
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
          }
          // not logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
