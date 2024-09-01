import "package:another_carousel_pro/another_carousel_pro.dart";
import "package:flutter/material.dart";
import "package:locket_flutter/components/shop_item.dart";
import "package:locket_flutter/connection/auth/LocketAuth.dart";
import "package:locket_flutter/connection/database/LocketDatabase.dart";

class LandingPage extends StatefulWidget {
  final Function() goToSearch;
  const LandingPage({super.key, required this.goToSearch});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final searchStateController = TextEditingController();
  final currentUser = LocketAuth().getCurrentUserInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffd9d9d9),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            centerTitle: true,
            backgroundColor: const Color(0xff211a2c),
            title: const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text("LocKet",
                  style: TextStyle(
                      color: Color(0xffffaf36),
                      fontWeight: FontWeight.bold,
                      fontSize: 25)),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Color(0xff211a2c),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40))),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onTap: widget.goToSearch,
                        style: TextStyle(
                            height: MediaQuery.of(context).size.height * 0.001),
                        // controller: searchStateController,
                        controller: searchStateController,
                        decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff28293f)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff28293f)),
                            ),
                            fillColor: const Color(0xff28293f),
                            filled: true,
                            hintText: "What do you want to buy today?",
                            hintStyle: TextStyle(color: Colors.grey[600])),
                        readOnly: true,
                      )),
                  const SizedBox(
                    height: 25,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 25, top: 20),
                    child: Text(
                      "What's new",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SizedBox(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: AnotherCarousel(
                          images: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset("assets/images/news1.png",
                                  fit: BoxFit.cover),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset("assets/images/news2.png",
                                  fit: BoxFit.cover),
                            ),
                          ],
                          dotSize: 4.0,
                          dotSpacing: 15.0,
                          dotColor: const Color(0xffffaf36),
                          indicatorBgPadding: 5.0,
                          borderRadius: true,
                        )),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25, top: 15, bottom: 15),
              child: Text(
                "Latest items",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 0.30,
              child: StreamBuilder(
                stream: LocketDatabase().getShopItemsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final item = snapshot.data!.docs;
                    return StreamBuilder(
                        stream: LocketAuth().getCurrentUserSnapShot(),
                        builder: (context, snapshots) {
                          if (snapshots.data != null) {
                            final userData =
                                snapshots.data!.data() as Map<String, dynamic>;
                            return ListView.builder(
                                itemCount: item.length,
                                itemBuilder: (context, index) {
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
                                });
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
        ));
  }
}
