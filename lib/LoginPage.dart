import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginWith {
  AssetImage image;
  Function signInAction;
  Function signOutAction;
  String loginText;

  LoginWith(
      {@required this.signInAction,
      this.image,
      @required this.loginText,
      this.signOutAction});
}

class LoginPage extends StatelessWidget {
  List<LoginWith> loginWith;

  LoginPage({Key key, @required this.loginWith}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
//        color: Colors.deepPurple[800],
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.deepPurple[800], Colors.red])),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Leave Me Alone!',
                style: GoogleFonts.architectsDaughter(
                  fontSize: 55,
                  letterSpacing: 10,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.pink.shade900.withOpacity(1),
                      offset: Offset(5, 5),
                      blurRadius: 5,
                    ),
                  ],
                ),
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                  width: 320.0,
                  height: 320.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new AssetImage("images/bgsticker.png"),
                      ))),
              SizedBox(height: 50),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: loginWith?.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      _signInButton(loginWith.elementAt(index)),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _signInButton(LoginWith loginWith) {
  return OutlineButton(
    splashColor: Colors.grey,
    onPressed: loginWith.signInAction,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
    highlightElevation: 0,
    borderSide: BorderSide(color: Colors.white),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(image: loginWith.image, height: 35.0),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              loginWith.loginText,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    ),
  );
}
