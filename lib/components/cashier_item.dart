import 'package:flutter/material.dart';
import 'package:locket_flutter/connection/database/LocketDatabase.dart';
import 'package:locket_flutter/util/currency_formatter.dart';

class CashierItem extends StatelessWidget {
  final String email;
  final List items;
  final String nama;
  final int total;
  const CashierItem({super.key, required this.email, required this.items, required this.nama, required this.total});

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
      child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ 
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 5, bottom: 10),
                child: Text(
                  "Order from ${nama}",
                  style: const TextStyle( 
                    fontWeight: FontWeight.bold,
                    fontSize: 17
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      "${items[index]['nama']} X${items[index]['amount']}",
                      style: const TextStyle( 
                        fontSize: 14
                      ),
                    ),
                  );
                }
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 10, bottom: 10),
                child: Text(
                  "Total : ${CurrencyFormat.convertToIdr(total, 0)}",
                  style: const TextStyle( 
                    fontWeight: FontWeight.bold,
                    fontSize: 17
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ElevatedButton(
                  onPressed: () {
                    LocketDatabase().finishOrder(email);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffffaf36),
                    fixedSize: Size(MediaQuery.of(context).size.width * 0.45, 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                  ),
                  child: const Text("Finish order", maxLines: 1, style: TextStyle( 
                    color: Colors.white
                  ),),
                  
                ),
              ),
            ],
          ),
    );
  }
}