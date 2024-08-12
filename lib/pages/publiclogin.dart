// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:http/http.dart';
import 'package:osl_umcollect/pages/incidences.dart';

import '../Components/SubmitButton.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Components/Utils.dart';

class PublicLogin extends StatefulWidget {
  const PublicLogin({super.key});

  @override
  State<StatefulWidget> createState() => _PublicLoginState();
}

class _PublicLoginState extends State<PublicLogin> {
  String phone = '';
  String password = '';
  String error = '';
  bool successful = false;
  var isLoading;
  final storage = const FlutterSecureStorage();

  String appendIfNotExists(String idString, String newId) {
    List<String> idList = idString.split("=");
    String newIdString = newId.toString();
    if (!idList.contains(newIdString)) {
      idList.add(newIdString);
    }
    return idList.join("=");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "UM Collect Staff Login",
      home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(),
          body: Stack(children: <Widget>[
            Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: Colors.white54),
                child: Center(
                  child: SizedBox(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 0, 24),
                            child: Center(
                                child: Image.asset(
                              'assets/images/logo.png',
                              width: 200,
                            )),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Form(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    const Text(
                                      "KWCL",
                                      style: TextStyle(
                                          fontSize: 32,
                                          color:
                                              Color.fromARGB(255, 28, 100, 140),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    const Text(
                                      "Incident Reporting",
                                      style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    SubmitButton(
                                      label: "Proceed",
                                      onButtonPressed: () async {
                                        await storage.write(
                                            key: 'isstaff', value: 'false');

                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const Incidences()));
                                      },
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  ])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            Center(child: isLoading),
          ])),
    );
  }
}

Future<Message> publicLogin(String phone, String password) async {
  if (phone.isEmpty || password.isEmpty) {
    return Message(
      token: null,
      success: null,
      error: "Empty Field!!",
    );
  }

  if (password.length < 6) {
    return Message(
      token: null,
      success: null,
      error: "Password is too short!",
    );
  }

  try {
    final response = await post(
      Uri.parse("${getUrl()}publicusers/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'Phone': phone, 'Password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 203) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      return Message(
        token: null,
        success: null,
        error: "Server error! Contact administrator.",
      );
    }
  } catch (e) {
    return Message(
      token: null,
      success: null,
      error: "Connection failed! Check your internet connection.",
    );
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
