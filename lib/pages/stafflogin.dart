// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:http/http.dart';
import 'package:osl_umcollect/pages/TextOakar.dart';
import 'package:osl_umcollect/pages/home.dart';

import '../Components/SubmitButton.dart';
import '../Components/MyTextInput.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Components/Utils.dart';

class StaffLogin extends StatefulWidget {
  const StaffLogin({super.key});

  @override
  State<StatefulWidget> createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> {
  String email = '';
  String password = '';
  String error = '';
  var isLoading;
  bool successful = false;

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
          body: SingleChildScrollView(
            child: Stack(children: <Widget>[
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
                                        "Staff Login",
                                        style: TextStyle(
                                            fontSize: 44,
                                            color: Colors.deepOrange,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextOakar(label: error),
                                      MyTextInput(
                                        title: 'Email Address',
                                        value: '',
                                        type: TextInputType.emailAddress,
                                        onSubmit: (value) {
                                          setState(() {
                                            email = value;
                                          });
                                        },
                                        lines: 1,
                                      ),
                                      MyTextInput(
                                        title: 'Password',
                                        value: '',
                                        type: TextInputType.visiblePassword,
                                        onSubmit: (value) {
                                          setState(() {
                                            password = value;
                                          });
                                        },
                                        lines: 1,
                                      ),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text("Forgot password?",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                )),
                                            const SizedBox(
                                              width: 0,
                                            ),
                                            TextButton(
                                              onPressed: () {},
                                              child: const Text(
                                                "Click Here",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.deepOrange),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SubmitButton(
                                        label: "Login",
                                        onButtonPressed: () async {
                                          setState(() {
                                            error = "";
                                            isLoading = LoadingAnimationWidget
                                                .twistingDots(
                                              leftDotColor:
                                                  Colors.deepOrangeAccent,
                                              rightDotColor: Colors.deepOrange,
                                              size: 100,
                                            );
                                          });
                                          var res =
                                              await staffLogin(email, password);
                                          setState(() {
                                            isLoading = null;
                                            if (res.error == null) {
                                              successful = true;
                                              error = res.success;
                                            } else {
                                              successful = false;
                                              error = res.error;
                                            }
                                          });
                                          if (res.error == null) {
                                            await storage.write(
                                                key: 'kwstaffjwt',
                                                value: res.token);

                                            await storage.write(
                                                key: 'isstaff', value: 'true');

                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        const Home()));
                                          }
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
            ]),
          )),
    );
  }
}

Future<Message> staffLogin(String email, String password) async {
  final bool emailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
  if (!emailValid) {
    return Message(
      token: null,
      success: null,
      error: "Invalid Email!",
    );
  }
  if (password.length < 5) {
    return Message(
      token: null,
      success: null,
      error: "Password is too short!",
    );
  }
  try {
    final response = await post(
      Uri.parse("${getUrl()}mobile/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'Email': email, 'Password': password}),
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
      error: "Connection failed! Check your internet connection.!",
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
      error: "Connection failed! Check your internet connection.!",
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
