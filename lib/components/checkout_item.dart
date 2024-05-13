import "package:flutter/material.dart";
import "package:locket_flutter/connection/database/LocketDatabase.dart";
import "package:locket_flutter/util/currency_formatter.dart";

class CheckoutItem extends StatefulWidget {
  final int harga;
  final String imageLink;
  final String nama;
  final int amount;
  final String email;
  final bool isOrdering;
  const CheckoutItem({super.key, required this.harga, required this.imageLink, required this.nama, required this.amount, required this.email, required this.isOrdering});

  @override
  State<CheckoutItem> createState() => _CheckoutItemState();
}

class _CheckoutItemState extends State<CheckoutItem> {
  bool enableButton = true;

  Future<void> delete() async {
    setState(() {
      enableButton = false;
    });
    var docSnapshot = await LocketDatabase().getCheckoutItemsData(widget.email);
    var shopSnapshot = await LocketDatabase().getShopItemData(widget.nama);
    Map<String, dynamic> data = shopSnapshot.data()!;
    var jumlahItem = data['stock'];

    if(jumlahItem > 0) {
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        var value = data?['items'];
        var totalBefore = data?['total'];
        for (var i = 0; i < value.length; i++) {
          // TO DO
          if(value[i]["nama"] == widget.nama) {
            int amountBefore = value[i]["amount"];
            value.removeAt(i);
            LocketDatabase().updateCheckoutData(widget.email,               
              {
                "items": value,
                "total": totalBefore-(widget.amount*widget.harga)
              }
            );
            LocketDatabase().updateShopItemData(widget.nama, "stock", jumlahItem+amountBefore);
            // checkoutCollection.doc(widget.email).update(
            //   {
            //     "items": value,
            //     "total": totalBefore-(widget.amount*widget.harga)
            //   }
            // );
            // shopCollection.doc(widget.nama).update({"stock": jumlahItem+amountBefore});
          }
        }
        setState(() {
          enableButton = true;
        });

      }
    }
  }

  Future<void> minus() async {
    setState(() {
      enableButton = false;
    });
    var docSnapshot = await LocketDatabase().getCheckoutItemsData(widget.email);
    var shopSnapshot = await LocketDatabase().getShopItemData(widget.nama);
    Map<String, dynamic> data = shopSnapshot.data()!;
    var jumlahItem = data['stock'];
    if(jumlahItem > 0) {
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        var value = data?['items'];
        var totalBefore = data?['total'];
        for (var i = 0; i < value.length; i++) {
          // TO DO
          if(value[i]["nama"] == widget.nama) {
            int amountBefore = value[i]["amount"];
            if(amountBefore-1 > 0) {
              value[i] = {
                "nama": widget.nama,
                "harga": widget.harga,
                "amount": amountBefore - 1,
                "imgLink": widget.imageLink
              };
              LocketDatabase().updateCheckoutData(widget.email,                 
                {
                  "items": value,
                  "total": totalBefore - widget.harga
                }
              );
              LocketDatabase().updateShopItemData(widget.nama, "stock", jumlahItem+1);
              // checkoutCollection.doc(widget.email).update(
              //   {
              //     "items": value,
              //     "total": totalBefore - widget.harga
              //   }
              // );
              // shopCollection.doc(widget.nama).update({"stock": jumlahItem+1});
            } else {
              value.removeAt(i);
              LocketDatabase().updateCheckoutData(widget.email,                 
                {
                  "items": value,
                  "total": totalBefore - widget.harga
                }
              );
              LocketDatabase().updateShopItemData(widget.nama, "stock", jumlahItem+1);
              // checkoutCollection.doc(widget.email).update(
              //   {
              //     "items": value,
              //     "total": totalBefore - widget.harga
              //   }
              // );
              // shopCollection.doc(widget.nama).update({"stock": jumlahItem+1});
            }

            
          }
        }
        setState(() {
          enableButton = true;
        });

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container( 
        decoration: BoxDecoration( 
          color: Colors.white,
          borderRadius: BorderRadius.circular(8)
        ),
        width: MediaQuery.of(context).size.width * 1,
        padding: const EdgeInsets.only(bottom: 15, top: 15),
        margin: const EdgeInsets.only(left:20, right:20, top:20),
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.59,
                  child: Row( 
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [ 
                      Text(
                        widget.nama.length > 20 ? "${widget.nama.substring(0,21)}..." : widget.nama,
                        style: const TextStyle( 
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      
                      widget.isOrdering ? const SizedBox(height: 40, width: 40,) : IconButton(
                        onPressed: enableButton ? () {delete();} : null,
                        icon: const Icon( 
                          Icons.delete
                        )
                      )
                    ],
                  ),
                ),
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
                // const SizedBox(height: 10,),
                Row(                  
                  children: [ 
                    Row( 
                      children: [ 
                        const Icon( 
                          Icons.shopping_cart,
                          size: 17,
                          color: Color(0xffffaf36),
                        ),
                        const SizedBox(width: 5,),
                        Text(
                          "${widget.amount} ordered",
                          style: const TextStyle( 
                            fontSize: 11
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 60,),
                    
                    widget.isOrdering ? const SizedBox(height: 40, width: 40,) : MaterialButton(
                      onPressed: enableButton ? () {minus();} : null,
                      height: 10, 
                      minWidth: 10, 
                      color: const Color(0xffffaf36),
                      textColor: Colors.white, 
                      child: const Icon(Icons.remove, color: Colors.white,),        
                    ),
                    

                  ],
                )
              ],
            ),
          ],
        ),
      );

  }
}