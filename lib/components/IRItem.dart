import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/pages/reportIncident.dart';

class IRItem extends StatefulWidget {
  final String incident;
  final String asset;
  final String image;
  const IRItem({
    super.key,
    required this.incident,
    required this.asset,
    required this.image,
  });

  @override
  State<IRItem> createState() => _CollectedItemState();
}

class _CollectedItemState extends State<IRItem> {
  Map<String, dynamic> data = {};
  final storage = const FlutterSecureStorage();

  @override
  initState() {
    super.initState();
  }

  DateTime parsePostgresTimestamp(String timestamp) {
    return DateTime.parse(timestamp)
        .toLocal(); // Parse timestamp and convert to local time
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ReportIncident(widget.incident)));
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Image.asset(
                  widget.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )),
            Expanded(
                child: Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(mainAxisSize: MainAxisSize.max, children: [
                  Image.asset(
                    widget.asset,
                    fit: BoxFit.cover,
                  ),
                  Divider(),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.incident,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 28, 100, 140)),
                      ),
                    ),
                  )
                ]),
              ),
            ))
          ],
        ),
      ),
    ));
  }
}

class Message {
  var token;
  var success;
  var error;

  Message({
    required this.token,
    required this.success,
    required this.error,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      token: json['token'],
      success: json['success'],
      error: json['error'],
    );
  }
}
