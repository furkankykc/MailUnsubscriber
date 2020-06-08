import 'dart:convert';

import 'package:googleapis/gmail/v1.dart';

class Mail {
  final List<MessagePartHeader> headerPart;
  final MessagePartBody bodyPart;
  final String mailThread;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mail &&
          runtimeType == other.runtimeType &&
          this.fromMail == other.fromMail;

  @override
  int get hashCode => fromMail.hashCode;

  bool get hasunsub {
    if (this.listunsub.isEmpty) return false;
    return true;
  }

  Mail({this.mailThread, this.headerPart, this.bodyPart});

  String get from {
    var _from = this.headerPart.firstWhere((element) => element.name == 'From');

    return _from.value ?? '';
  }

  String get fromName {
    var _from = this.from.split('<');
    return cleaner(_from[0]);
  }

  String get fromMail {
    var _from = this.from.split('<');
    return cleaner(_from[1]);
  }

  cleaner(String source) {
    return source
        .replaceAll(' ', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '');
  }

  String get message {
    String _message = "";
    if (this.bodyPart != null)
      try {
        var data = this.bodyPart.toJson()['data'];
        _message = utf8.decode(Base64Codec().decode(data));
      } catch (Exception) {}
    return _message.toString();
  }

  String get unsubscribe {
    var _unsublink = '';
    RegExp exp = new RegExp(
        r"(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})");
    Iterable<RegExpMatch> matches = exp.allMatches(message);
    matches.forEach((element) {
      print('Match :${element.group(0)}');
    });
    return _unsublink.toString();
  }

  String get listunsub {
    try {
      var _listunsub = this
          .headerPart
          .firstWhere((element) => element.name == 'List-Unsubscribe');
      if (_listunsub != null) return _listunsub.value ?? '';
    } catch (Exception) {}

    return '';
  }

  String get unsubMail {
    var _unsub = this.listunsub.split(',');
    var mail = '';
    _unsub.forEach((element) {
      if (element.contains('mailto')) mail = cleaner(element);
    });

    return mail;
  }

  String get unsubUrl {
    var _unsub = this.listunsub.split(',');
    var url = '';
    _unsub.forEach((element) {
      if (!element.contains('mailto')) url = cleaner(element);
    });

    return url;
  }
}
