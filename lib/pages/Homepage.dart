import 'package:flutter/material.dart';
import 'package:locket_flutter/connection/auth/LocketAuth.dart';
import 'package:locket_flutter/pages/Account.dart';
import 'package:locket_flutter/pages/Checkout.dart';
import 'package:locket_flutter/pages/LandingPage.dart';
import 'package:locket_flutter/pages/SearchItem.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {


  int _currentIndex = 0;

  static void signOut() {
    LocketAuth().signOut();
  }

  void goToSearchs() {
    setState(() {
      _currentIndex = 1;
    });
  }

  static List<Widget> pages =[
    const SizedBox(height: 0, width: 0,),
    const SearchItem(),
    const Checkout(),
    const Account(signOut: signOut)
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: () {
        if (_currentIndex != 0) {
          return pages[_currentIndex];
        } else {
          return LandingPage(goToSearch: goToSearchs);
        }
      }(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Checkout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_rounded),
            label: "Profile",
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xffffaf36),
      ),

    );
  }
}