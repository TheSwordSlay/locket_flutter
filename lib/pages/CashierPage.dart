import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locket_flutter/components/cashier_item.dart';

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff211a2c),
        title: const Text("Cashier", style: TextStyle(color: Color(0xffffaf36)),), 
        actions: [
          IconButton(onPressed: signOut, 
          icon: const Icon(Icons.logout),
          color: const Color(0xffffaf36),)
        ],
      ),
      backgroundColor: const Color(0xffd9d9d9),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Orders").snapshots(), 
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            final item = snapshot.data!.docs;
            return ListView.builder(
              itemCount: item.length,
              itemBuilder: (context, index) {
                return CashierItem(email: item[index]['email'], items: item[index]['items'], nama: item[index]['nama'], total: item[index]['total'],);
              }
            );
          } else if (snapshot.hasError) {
            return Center( 
              child: Text("Error : ${snapshot.error}"),
            );
          }
          return const Center( 
            child: CircularProgressIndicator(),
          );
        }),
    );
  }
}