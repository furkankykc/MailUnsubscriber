// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:MailUnsubscriber/Entity/Mail.dart';
import 'package:MailUnsubscriber/Safety/privacy.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/io_client.dart';
import 'package:http/http.dart';

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
final identifier = new auth.ClientId(
    currentidentity,
    "<please fill in>");

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
  String _contextText = "12345";
  List<Mail> entries = new List();

  @override
  void initState() {
    super.initState();
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

      if (item != null)
        setState(() {
          if (entries != null) {
            var mail = new Mail(
                mailThread: item.threadId,
                headerPart: item.payload.headers,
                bodyPart: item.payload.body);
            if (mail.hasunsub) {
              entries.add(mail);
            }
          }
        });
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

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: GoogleUserCircleAvatar(
                identity: _currentUser,
              ),
              title: Text(_currentUser.displayName ?? ''),
              subtitle: Text(_currentUser.email ?? ''),
            ),
            const Text("Signed in successfully."),
            Expanded(
              child: SizedBox(
                height: 200.0,
                child: ListView.builder(
//                  shrinkWrap: true,
                  itemCount: entries?.length,

                  itemBuilder: (context, index) {
//                    if(unsub!=null)
//                    text =unsub.value ?? '';

                    return ListTile(
                      title:
                          Text('${entries.elementAt(index).from}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(mail: entries.elementAt(index))),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: const Text('SIGN OUT'),
                    onPressed: _handleSignOut,
                  ),
                  SizedBox(width: 20),
                  RaisedButton(
                    child: const Text('REFRESH'),
                    onPressed: _handleGetMails,
                  )
                ]),
          ]);
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          RaisedButton(
            child: const Text('SIGN IN'),
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
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

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(mail.from),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GestureDetector(
            onTap: () {
//              mail.headerPart.forEach((element) {print(element.name);});
              print(mail.mailThread);
            },
            child: Text(mail.listunsub)),
      ),
    );
  }
}
