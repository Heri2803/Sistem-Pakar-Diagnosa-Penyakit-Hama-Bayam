import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/user/home_page.dart';
import 'package:frontend/admin/admin_page.dart';
import 'package:frontend/user/before_login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = BeforeLogin(); // Default sebelum login

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('user_role'); // Ambil role dari penyimpanan lokal

    if (role == 'admin') {
      setState(() {
        _initialScreen = AdminPage(); // Jika admin, ke halaman admin
      });
    } else if (role == 'user') {
      setState(() {
        _initialScreen = HomePage(); // Jika user, ke halaman user
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistem Pakar Bayam',
      home: _initialScreen,
    );
  }
}
