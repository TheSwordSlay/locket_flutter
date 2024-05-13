import "package:flutter/material.dart";

class ProfileBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final bool isShowButton;
  final void Function()? onPressed;
  const ProfileBox({super.key, required this.text, required this.sectionName, required this.onPressed, required this.isShowButton});

  @override
  Widget build(BuildContext context) {
    Widget returnButton(bool isShow) {
      if (isShow) {
        return IconButton(
          onPressed: onPressed, 
          icon: const Icon( 
            Icons.settings
          )
        );
      }
      return IconButton(
        onPressed: () {}, 
        icon: const Icon( 
          Icons.settings
        )
      );
    }

    return Container( 
      decoration: BoxDecoration( 
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8)
      ),
      width: MediaQuery.of(context).size.width * 1,
      padding: const EdgeInsets.only(bottom: 15, left: 15,),
      margin: const EdgeInsets.only(left:20, right:20, top:20),
      child: Column( 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [ 
              Text(
                sectionName,
                style: TextStyle( 
                  color: Colors.grey[600]
                ),
              ),
              returnButton(isShowButton)
            ],
          ),

          Text(text)
        ],
      ),
    );
  }
}