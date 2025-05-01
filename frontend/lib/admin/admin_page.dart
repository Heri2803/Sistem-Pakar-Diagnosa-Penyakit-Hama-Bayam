import 'package:flutter/material.dart';
import 'hama_page.dart';
import 'penyakit_page.dart';
import 'gejala_page.dart';
import 'rule_page.dart';
import 'package:frontend/api_services/api_services.dart';
import 'package:frontend/user/login_page.dart';

class AdminPage extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    await ApiService.logoutUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      drawer: Drawer(
        child: Container(
          color: Color(0xFFFFFFFF),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 70,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xFF9DC08D)),
                  child: Text(
                    'Menu Admin',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),

              ListTile(
                title: Text('Halaman Hama'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HamaPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Halaman Penyakit'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PenyakitPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Halaman Gejala'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GejalaPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Halaman Aturan'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RulePage()),
                  );
                },
              ),
              ListTile(title: Text('Logout'), onTap: () => _logout(context)),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang Admin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCard('Jumlah User', '10'),
                    _buildCard('Jumlah Diagnosa', '25'),
                  ],
                ),
                SizedBox(height: 16), // Spasi antar baris
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCard('Penyakit', '15'),
                    _buildCard('Hama', '15'),
                  ],
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, String count) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 160,
        height: 160,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(count, style: TextStyle(fontSize: 20, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
