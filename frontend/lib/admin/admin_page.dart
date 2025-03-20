import 'package:flutter/material.dart';
import 'hama_page.dart';
import 'penyakit_page.dart';
import 'gejala_page.dart';
import 'package:frontend/api_services/api_services.dart';
import 'package:frontend/user/login_page.dart';

class AdminPage extends StatelessWidget {
   Future<void> _logout(BuildContext context) async {
    await ApiService.logoutUser();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HamaPage()),
                );
              },
              child: Text('Halaman Hama'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PenyakitPage()),
                );
              },
              child: Text('Halaman Penyakit'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GejalaPage()),
                );
              },
              child: Text('Halaman Gejala'),
            ),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}