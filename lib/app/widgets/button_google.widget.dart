import 'package:flutter/material.dart';


class ButtonGoogleSignIn extends StatelessWidget {

  final dynamic Function() onPressed; 

  const ButtonGoogleSignIn({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: Colors.black12)
      ),
      onPressed: onPressed,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          Image(
            image: AssetImage("assets/logos/google.png"),
            height: (18*2.4),
          ),
          SizedBox(width: 24),
          Text("Iniciar sesión con Google",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              fontFamily: "Roboto",
              color: Colors.black54,),)
        ],
      ),
    );
  }


}