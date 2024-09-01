import "package:flutter/material.dart";
import "package:locket_flutter/components/shop_item.dart";
import "package:locket_flutter/connection/auth/LocketAuth.dart";
import "package:locket_flutter/connection/database/LocketDatabase.dart";

class SearchItem extends StatefulWidget {
  const SearchItem({super.key});

  @override
  State<SearchItem> createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  final currentUser = LocketAuth().getCurrentUserInstance();
  final searchStateController = TextEditingController();

  String search = "";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff211a2c),
      body: SingleChildScrollView( 
        child:       Column( 
        children: [ 
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: MediaQuery.of(context).size.height * 0.05),
            child: TextField(
              style: TextStyle(height: MediaQuery.of(context).size.height * 0.001),
              controller: searchStateController,
              obscureText: false,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                fillColor: Colors.grey.shade300,
                filled: true,
                hintText: "Search item here",
                hintStyle: TextStyle(color: Colors.grey[600])
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            )
          ),
          Container( 
            decoration: const BoxDecoration( 
              color: Color(0xffd9d9d9),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(40),
                topLeft: Radius.circular(40))
            ),
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 0.77,
            child: StreamBuilder( 
                stream: LocketDatabase().getShopItemsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final item = snapshot.data!.docs;
                    return StreamBuilder(
                      stream: LocketAuth().getCurrentUserSnapShot(),  
                      builder: (context, snapshots) {
                        if(snapshots.data != null) {
                          final userData = snapshots.data!.data() as Map<String, dynamic>;
                          return ListView.builder(
                            itemCount: item.length,
                            itemBuilder: (context, index) {
                              if(item[index]['nama'].toLowerCase().replaceAll(' ', '').contains(search.toLowerCase().replaceAll(' ', ''))) {
                                return ShopItem(
                                  harga: item[index]['harga'], 
                                  imageLink: item[index]['imageLink'], 
                                  nama: item[index]['nama'], 
                                  satuan: item[index]['satuan'], 
                                  stock: item[index]['stock'], 
                                  tipe: item[index]['tipe'],
                                  email: currentUser.email!,
                                  isOrdering: userData['isOrdering'],
                                );
                              }
                              return const SizedBox(height: 0, width: 0,);
                            }
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      });

                  } else if (snapshot.hasError) {
                    return Center( 
                      child: Text("Error : ${snapshot.error}"),
                    );
                  }
                  return const Center( 
                    child: CircularProgressIndicator(),
                  );
                },
              ),
          ),          
        ],
      ),
      )

    );
  }
}