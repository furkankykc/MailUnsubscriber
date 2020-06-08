// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:MailUnsubscriber/LoginPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:MailUnsubscriber/Entity/Mail.dart';
import 'package:MailUnsubscriber/Safety/privacy.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/io_client.dart';
import 'package:http/http.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[gmail.GmailApi.GmailReadonlyScope],
);
final identifier = new auth.ClientId(currentidentity, "<please fill in>");

void main() {
  runApp(
    MaterialApp(
      title: 'Google Sign In',
      home: SignInDemo(),
    ),
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount _currentUser;
  Set<Mail> entries = new Set();

  get entryList {
    return entries.toList();
  }

  @override
  void initState() {
    super.initState();
    if (loginList == null) loginList = new List<LoginWith>();
    loginList.add(LoginWith(
      signInAction: _handleSignIn,
      image: AssetImage("images/google_logo.png"),
      loginText: "Sign in with Google",
    ));
    loginList.add(LoginWith(
      signInAction: _handleSignIn,
      image: AssetImage("images/icloud_logo.png"),
      loginText: "Sign in with iCloud",
    ));

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetMails();
      }
    });
    _googleSignIn.signInSilently();
  }

  void getAllMails(gmail.ListMessagesResponse data) {
    data.messages.forEach((element) async {
      gmail.Message item = await getMail(element.threadId);

      if (item != null) {
        var mail = new Mail(
            mailThread: item.threadId,
            headerPart: item.payload.headers,
            bodyPart: item.payload.body);
        setState(() {
          if (entries != null) {
            if (mail.hasunsub) {
              entries.add(mail);
            }
          }
        });
      }
    });
  }

  void clearMails() {
    setState(() {
      if (entries != null) entries.clear();
    });
  }

  Future<gmail.Message> getMail(String id) async {
    final authHeaders = _googleSignIn.currentUser.authHeaders;
    if (authHeaders != null) {
      final httpClient = GoogleHttpClient(await authHeaders);

      var data = gmail.GmailApi(httpClient).users.messages.get('me', id);
      return data;
    }
    return null;
  }

  Future<void> _handleGetMails() async {
//    final Map<String, dynamic> data;
    final authHeaders = _googleSignIn.currentUser.authHeaders;
//
//    // custom IOClient from below
    final httpClient = GoogleHttpClient(await authHeaders);
    clearMails();
    var data = await gmail.GmailApi(httpClient)
        .users
        .messages
        .list('me', includeSpamTrash: true);
    getAllMails(data);
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();
  List<LoginWith> loginList;

  Widget _buildBody() {
    if (_currentUser != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple[800],
          title: const Text('Mail Unsubscriber'),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.start, children: <
            Widget>[
          ListTile(
              leading: GoogleUserCircleAvatar(
                identity: _currentUser,
              ),
              title: Text(_currentUser.displayName ?? ''),
              subtitle: Text(_currentUser.email ?? ''),
              trailing: ClipOval(
                child: Material(
                  color: Colors.blueGrey[50], // button color
                  child: InkWell(
                    splashColor: Colors.deepPurple[800], // inkwell color
                    child: SizedBox(
                        width: 46, height: 46, child: Icon(Icons.exit_to_app)),
                    onTap: _handleSignOut,
                  ),
                ),
              )),
          Divider(
            height: 1,
            thickness: 1,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleGetMails,
              child: ListView.builder(
//                  shrinkWrap: true,
                itemCount: entryList?.length,

                itemBuilder: (context, index) {
//                    if(unsub!=null)
//                    text =unsub.value ?? '';

//                    return ListTile(
//                      title: Text('${entryList.elementAt(index).fromName}'),
//                      subtitle: Text('${entryList.elementAt(index).fromMail}'),
//                      onTap: () {
//                        Navigator.push(
//                          context,
//                          MaterialPageRoute(
//                              builder: (context) =>
//                                  DetailScreen(mail: entryList.elementAt(index))),
//                        );
//                      },
//                    );
                  return Column(
                    children: <Widget>[
                      Container(
                        child: Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          child: Container(
                            decoration: new BoxDecoration(
                              color: entryList.elementAt(index).isSelected
                                  ? Colors.red
                                  : Colors.white,
                            ),
                            child: ListTile(
                              title: Text(
                                  '${entryList.elementAt(index).fromName}'),
                              subtitle: Text(
                                  '${entryList.elementAt(index).fromMail}'),
                              onTap: () {
//                              Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (context) => DetailScreen(
//                                        mail: entryList.elementAt(index))),
//                              );
                                setState(() {
                                  entryList.elementAt(index).toggleSelected();
                                });
                              },
                            ),
                          ),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Mail',
                              color: Colors.blueGrey,
                              icon: Icons.mail,
                              onTap:
                                  entryList.elementAt(index).unsubMail.isEmpty
                                      ? null
                                      : () async {
                                          launch(
                                              '${entryList.elementAt(index).unsubMail}');
                                        },
                            ),
                            IconSlideAction(
                              caption: 'Url',
                              color: Colors.red,
                              icon: Icons.web,
                              onTap: entryList.elementAt(index).unsubUrl.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => WebScreen(
                                                mail: entryList
                                                    .elementAt(index))),
                                      );
                                    },
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 0.01,
                        height: 1,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ]),
        floatingActionButton:
            !entries.any((element) => element.isSelected == true)
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      entries.forEach((element) async => {
                            if (element.isSelected == true)
                              {
                                if ((await http.get(element.unsubUrl)
                                            as http.Response)
                                        .statusCode ==
                                    200)
                                  {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Unsubscribed from ${element.fromName}",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIos: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0),
                                  }
                              }
                          });
                    },
                    child: Icon(Icons.accessibility_new),
                    tooltip: 'Unsubscribe Selected',
                    backgroundColor: Colors.green,
                  ),
      );
    } else {
      return LoginPage(
        loginWith: loginList,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        appBar: AppBar(
//          title: const Text('Mail Unsubscriber'),
//        ),
        body: ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: _buildBody(),
    ));
  }
}

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Todo.
  final Mail mail;

  // In the constructor, require a Todo.
  DetailScreen({Key key, @required this.mail}) : super(key: key);

  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
        appBar: AppBar(
          title: Text(mail.fromName),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: GestureDetector(
              onTap: () {
//              mail.headerPart.forEach((element) {print(element.name);});
                print(mail.mailThread);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    onPressed: mail.unsubMail.isEmpty
                        ? null
                        : () async {
                            launchURL('${mail.unsubMail}');
                          },
                    child: Text('Mail'),
                  ),
                  FlatButton(
                    onPressed: mail.unsubUrl.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebScreen(mail: mail)),
                            );
                          },
                    child: Text('URL'),
                  ),
                ],
              )),
        ));
  }
}

class WebScreen extends StatelessWidget {
  // Declare a field that holds the Todo.
  final Mail mail;

  // In the constructor, require a Todo.
  WebScreen({Key key, @required this.mail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(mail.fromName),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GestureDetector(
            onTap: () {
//              mail.headerPart.forEach((element) {print(element.name);});
              print(mail.mailThread);
            },
            child: WebView(
              initialUrl: '${mail.unsubUrl}',
              javascriptMode: JavascriptMode.unrestricted,
            )),
      ),
    );
  }
}
