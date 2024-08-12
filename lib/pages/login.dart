// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/pages/publiclogin.dart';
import 'package:osl_umcollect/pages/stafflogin.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  int _selectedItem = 0;
  final _pageController = PageController();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    checkSelection();
    super.initState();
  }

  checkSelection() async {
    var index = await storage.read(key: "login_option");
    if (index == null) {
      setState(() {
        index = '0';
      });
    }
    setState(() {
      _selectedItem = int.parse(index as String);
      _pageController.animateToPage(_selectedItem,
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (index) {
          _selectedItem = index;
        },
        controller: _pageController,
        children: const [PublicLogin(), StaffLogin()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.login_rounded), label: 'Public Module'),
          BottomNavigationBarItem(
              icon: Icon(Icons.login), label: 'Staff Login'),
        ],
        currentIndex: _selectedItem,
        onTap: (index) {
          storage.write(key: "login_option", value: index.toString());
          setState(() {
            _selectedItem = index;
            _pageController.animateToPage(_selectedItem,
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear);
          });
        },
        fixedColor: Colors.orange,
      ),
    );
  }
}
