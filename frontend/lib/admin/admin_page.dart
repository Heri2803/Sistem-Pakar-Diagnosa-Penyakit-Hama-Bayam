import 'package:flutter/material.dart';
import 'dart:async';
import 'hama_page.dart';
import 'penyakit_page.dart';
import 'gejala_page.dart';
import 'rule_page.dart';
import 'user_list_page.dart';
import 'admin_histori_page.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
import 'package:SIBAYAM/user/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _lastKnownDiagnosisCount = 0;
  static const String DIAGNOSIS_COUNT_KEY = 'diagnosis_count';
  static const String LAST_KNOWN_COUNT_KEY = 'last_known_count';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadSavedCounts();
  }

  // Pindahkan method ke luar dari _loadDashboardData
  Future<void> _loadSavedCounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      diagnosisCount = prefs.getInt(DIAGNOSIS_COUNT_KEY) ?? 0;
      _lastKnownDiagnosisCount = prefs.getInt(LAST_KNOWN_COUNT_KEY) ?? 0;
    });
  }

  Future<void> _saveCounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(DIAGNOSIS_COUNT_KEY, diagnosisCount);
    await prefs.setInt(LAST_KNOWN_COUNT_KEY, _lastKnownDiagnosisCount);
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

      // Modified diagnosis count logic
      final allHistori = await ApiService().getAllHistori();
      int currentCount = allHistori.length;

      if (currentCount > _lastKnownDiagnosisCount) {
        int newDiagnoses = currentCount - _lastKnownDiagnosisCount;
        diagnosisCount += newDiagnoses;
        _lastKnownDiagnosisCount = currentCount;

        // Save the updated counts
        await _saveCounts();

        print("New diagnoses added: $newDiagnoses");
        print("Total diagnosis count: $diagnosisCount");
      }
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
              ListTile(
                title: Text('Halaman Histori User'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminHistoriPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Data Pengguna'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserListPage()),
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
