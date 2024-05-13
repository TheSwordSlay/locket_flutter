import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:locket_flutter/components/checkout_item.dart";
import "package:locket_flutter/components/toast.dart";
import "package:locket_flutter/util/currency_formatter.dart";

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool buttonEnable = true;

  Future<void> order(List items, String nama, int total, bool isThereItems) async {
    if (isThereItems) {
      setState(() {
        buttonEnable = false;
      });
      FirebaseFirestore.instance
        .collection("Orders")
        .doc(currentUser.email)
        .set({
          'nama' : nama,
          'email' : currentUser.email,
          'items' : items,
          'total' : total
        });
      FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.email)
        .update({
          'isOrdering': true
        });
      setState(() {
        buttonEnable = true;
      });
    }
    else {
      showToast(message: "Cant place order if checkout list is empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff211a2c),
        title: const Text("Checkout", style: TextStyle(color: Color(0xffffaf36)),), 
      ),
      backgroundColor: const Color(0xffd9d9d9),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Checkout").doc(currentUser.email).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            final checkOutData = snapshot.data!.data() as Map<String, dynamic>;
            final items = checkOutData['items'];
            return SingleChildScrollView( 
              child: Container( 
                width: MediaQuery.of(context).size.width * 1,
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25, top: 20),
                      child: Text(
                        "Checkout items :",
                        style: TextStyle( 
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(), 
                      builder: (context, snapshots) {
                        final userDatas = snapshots.data!.data() as Map<String, dynamic>;
                        return ListView.builder(
                          physics:NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            if(items[index]['amount'] > 0) {
                              return CheckoutItem(harga: items[index]['harga'], imageLink: items[index]['imgLink'], nama: items[index]['nama'], amount: items[index]['amount'], email: currentUser.email!, isOrdering: userDatas['isOrdering'],);
                            }
                            return const SizedBox(width: 0, height: 0,);
                          }
                        );
                      }
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 20),
                      child: Text(
                        "Total price : ${CurrencyFormat.convertToIdr(checkOutData['total'], 2)}",
                        style: const TextStyle( 
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(), 
                      builder: (context, snapshots) {
                        final userData = snapshots.data!.data() as Map<String, dynamic>;
                        return Center( 
                          child: ElevatedButton(
                            onPressed: userData['isOrdering'] || !buttonEnable ? null : (){
                              order(items, userData['username'], checkOutData['total'], items.length > 0);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffffaf36),
                              fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0),
                              ),
                            ),
                            child: Text(userData['isOrdering'] ? "Order placed" : "Place order", maxLines: 1, style: const TextStyle( 
                                color: Colors.white
                              ),
                            )
                          ),
                        );

                      }
                    ),
                    SizedBox(height: 30,)
                  ],
                )
              ),
            );                    
          } else if(snapshot.hasError) {
            return Center(
              child: Text("Error ${snapshot.error}"),
            );
          }
          return const Center( 
            child: CircularProgressIndicator(),
          );
        },
      ),

    );
  }
}