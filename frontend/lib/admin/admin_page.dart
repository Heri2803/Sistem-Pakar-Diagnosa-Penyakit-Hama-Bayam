import 'package:flutter/material.dart';
import 'dart:async';
import 'hama_page.dart';
import 'penyakit_page.dart';
import 'gejala_page.dart';
import 'rule_page.dart';
import 'package:frontend/api_services/api_services.dart';
import 'package:frontend/user/login_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Data counters
  int userCount = 0;
  int diagnosisCount = 0;
  int diseaseCount = 0;
  int pestCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Method untuk memuat data dashboard dari API
  Future<void> _loadDashboardData() async {
  try {
    setState(() {
      isLoading = true;
    });

    print("Fetching users with role 'user'...");

    // Mengambil jumlah user dengan role 'user'
    final userList = await ApiService().getUsers(role: 'user');
    if (userList != null && userList.isNotEmpty) {
      userCount = userList.length;
      print("Jumlah user: $userCount");
    } else {
      print("Tidak ada user dengan role 'user'.");
    }

    print("Fetching data penyakit...");
    // Mengambil data penyakit menggunakan fungsi yang sudah ada
    final penyakitList = await ApiService().getPenyakit();
    diseaseCount = penyakitList.length;
    print("Jumlah penyakit: $diseaseCount");

    print("Fetching data hama...");
    // Mengambil data hama menggunakan fungsi yang sudah ada
    final hamaList = await ApiService().getHama();
    pestCount = hamaList.length;
    print("Jumlah hama: $pestCount");

  } catch (e) {
    print("Error loading dashboard data: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


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
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Color(0xFF9DC08D),
      ),
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
              isLoading
                  ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF9DC08D)),
                  )
                  : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCard(
                            'Jumlah User',
                            userCount.toString(),
                            Icons.people,
                          ),
                          _buildCard(
                            'Jumlah Diagnosa',
                            diagnosisCount.toString(),
                            Icons.assignment,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCard(
                            'Penyakit',
                            diseaseCount.toString(),
                            Icons.sick,
                          ),
                          _buildCard(
                            'Hama',
                            pestCount.toString(),
                            Icons.bug_report,
                          ),
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

  Widget _buildCard(String title, String count, IconData icon) {
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
            Icon(icon, size: 40, color: Color(0xFF9DC08D)),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF9DC08D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
