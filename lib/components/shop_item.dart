import "package:flutter/material.dart";
import "package:locket_flutter/components/toast.dart";
import "package:locket_flutter/connection/database/LocketDatabase.dart";
import "package:locket_flutter/util/currency_formatter.dart";

class ShopItem extends StatefulWidget {
  final int harga;
  final String imageLink;
  final String nama;
  final String satuan;
  final int stock;
  final String tipe;
  final String email;
  final bool isOrdering;
  const ShopItem({super.key, required this.harga, required this.imageLink, required this.nama, required this.satuan, required this.stock, required this.tipe, required this.email, required this.isOrdering});

  @override
  State<ShopItem> createState() => _ShopItemState();
}

class _ShopItemState extends State<ShopItem> {

  Future<void> inputData(int amount) async {
    var docSnapshot = await LocketDatabase().getCheckoutItemsData(widget.email);
    // checkoutCollection.doc(widget.email).get();
    var shopSnapshot = await LocketDatabase().getShopItemData(widget.nama);
    // shopCollection.doc(widget.nama).get();
    Map<String, dynamic> data = shopSnapshot.data()!;
    var jumlahItem = data['stock'];

    if(jumlahItem > 0) {
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        var value = data?['items']; // <-- The value you want to retrieve. 
        // Call setState if needed.
        bool needSet = true;
        var totalBefore = data?['total'];
        for (var i = 0; i < value.length; i++) {
          // TO DO
          if(value[i]["nama"] == widget.nama) {
            int amountBefore = value[i]["amount"];
            if(amountBefore+amount > jumlahItem) {
              showToast(message: "The item doesn't have enough stock");
            } else {
              value[i] = {
                "nama": widget.nama,
                "harga": widget.harga,
                "amount": amountBefore + amount,
                "imgLink": widget.imageLink
              };
              LocketDatabase().updateCheckoutData(widget.email, 
                {
                  "items": value,
                  "total": totalBefore+ (amount*widget.harga)
                }
              );
              LocketDatabase().updateShopItemData(widget.nama, "stock", jumlahItem-amount);
              // checkoutCollection.doc(widget.email).update(
              //   {
              //     "items": value,
              //     "total": totalBefore+ (amount*widget.harga)
              //   }
              // );
              // shopCollection.doc(widget.nama).update({"stock": jumlahItem-amount});
              needSet = false;
            }
          }
        }
        if(needSet) {
          if(amount>jumlahItem) {
            showToast(message: "The item doesn't have enough stock");
          } else {
            var newValue = value + [{
                  "nama": widget.nama,
                  "harga": widget.harga,
                  "amount": amount,
                  "imgLink": widget.imageLink
                }];
            LocketDatabase().updateCheckoutData(widget.email,               
              {
                "items": newValue,
                "total": totalBefore+(amount*widget.harga)
              }
            );
            LocketDatabase().updateShopItemData(widget.nama, "stock", jumlahItem-amount);
            // checkoutCollection.doc(widget.email).set(
            //   {
            //     "items": newValue,
            //     "total": totalBefore+(amount*widget.harga)
            //   }
            // );
            // shopCollection.doc(widget.nama).update({"stock": jumlahItem-amount});
          }
        }
      } else {
        if(amount>jumlahItem) {
          showToast(message: "The item doesn't have enough stock");
        } else {
          LocketDatabase().updateCheckoutData(widget.email,             
            {
              "items": [{
                "nama": widget.nama,
                "harga": widget.harga,
                "amount": amount,
                "imgLink": widget.imageLink
              }],
              "total": (amount*widget.harga)
            }
          );
          LocketDatabase().updateShopItemData(widget.nama, "stock", jumlahItem-amount);
          // checkoutCollection.doc(widget.email).set(
          //   {
          //     "items": [{
          //       "nama": widget.nama,
          //       "harga": widget.harga,
          //       "amount": amount,
          //       "imgLink": widget.imageLink
          //     }],
          //     "total": (amount*widget.harga)
          //   }
          // );
          // shopCollection.doc(widget.nama).update({"stock": jumlahItem-amount});
        }

      }
    }
  }

  Future<void> order(String field) async {
    if(widget.isOrdering) {
      showToast(message: "Cant place a checkout before finishing placed order");
    } else {
      await showDialog(
        context: context,
        builder: (context) { 
          int newValue = 0;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog( 
                title: const Text(
                  "Order amount",
                  style: TextStyle( 
                    fontSize: 20
                  ),
                ),
                content: Row( 
                  children: [ 
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          newValue += 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffffaf36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                      ),
                      child: const Icon(Icons.add, color: Colors.white,),        
                    ),
                    const SizedBox(width: 5,),
                    Text("${newValue}", style: const TextStyle( fontSize: 20),),
                    const SizedBox(width: 5,),
                    ElevatedButton(
                      onPressed: () {
                        if(newValue > 0) {
                          setState(() {
                            newValue -= 1;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffffaf36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                      ),
                      child: const Icon(Icons.remove, color: Colors.white,),        
                    ),
                  ],
                ),
                actions: [ 
                  // cancel
                  TextButton(
                    onPressed: () => {
                      Navigator.pop(context),
                    }, 
                    child: const Text('Cancel')),

                  // save
                  TextButton(
                    onPressed: () async => {
                      Navigator.of(context).pop(newValue),
                      inputData(newValue)
                    }, 
                    child: const Text('Save')),
                ],
              );
            },
          ); 
        }
      );
    }


    // update firestore

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( 
      onTap: () {
        order(widget.nama);
      },
      child: Container( 
        decoration: BoxDecoration( 
          color: Colors.white,
          borderRadius: BorderRadius.circular(8)
        ),
        width: MediaQuery.of(context).size.width * 1,
        padding: const EdgeInsets.only(bottom: 15, top: 15),
        margin: const EdgeInsets.only(left:20, right:20, bottom:20),
        child: Row( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Image.network(
                widget.imageLink,
                width: MediaQuery.of(context).size.width * 0.2,
              ),
            ),

            const SizedBox(width: 10,),
            Column( 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                Text(
                  widget.nama.length > 20 ? widget.nama.substring(0,21)+"..." : widget.nama,
                  style: const TextStyle( 
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 3,),
                Text("Satuan : ${widget.satuan}",
                  style: const TextStyle( 
                    fontSize: 13 
                  ), 
                ),
                const SizedBox(height: 10,),
                Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ 
                    Row( 
                      children: [ 
                        const Icon( 
                          Icons.monetization_on_outlined,
                          size: 17,
                          color: Color(0xffffaf36),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(widget.harga, 2),
                          style: const TextStyle( 
                            fontSize: 11
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 30,),
                    Row( 
                      children: [ 
                        const Icon( 
                          Icons.type_specimen,
                          size: 17,
                          color: Color(0xffffaf36),
                        ),
                        const SizedBox(width: 5,),
                        Text(
                          widget.tipe,
                          style: const TextStyle( 
                            fontSize: 11
                          ),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  height: 2.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row( 
                  children: [ 
                    const Icon( 
                      Icons.check_circle,
                      size: 17,
                      color: Color(0xffffaf36),
                    ),
                    const SizedBox(width: 5,),
                    Text(
                      "${widget.stock} in stock",
                      style: const TextStyle( 
                        fontSize: 11
                      ),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );

  }
}