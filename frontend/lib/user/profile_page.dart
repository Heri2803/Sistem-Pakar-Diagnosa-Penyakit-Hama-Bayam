import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:frontend/api_services/api_services.dart';

class ProfilPage extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    await ApiService.logoutUser();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D),
      body: Stack(
        children: [
          // Judul halaman tetap di luar border (di bagian atas dan center)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0), // Jarak dari atas layar
              child: Column(
                children: [
                  Text(
                    "Profil Pengguna",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 80), // Menambah jarak antara judul dan card box
                ],
              ),
            ),
          ),

          // Ikon back di pojok kiri atas
          Positioned(
            top: 40.0,
            left: 16.0,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
            ),
          ),

          // Isi halaman
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card box untuk data pengguna
                  Container(
                    height: 400, // Atur tinggi card box
                    width: 450,  // Atur lebar card box
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileItem("Nama: John Doe"),
                            Divider(color: Colors.black), // Garis hitam pemisah
                            _buildProfileItem("Username: johndoe"),
                            Divider(color: Colors.black),
                            _buildProfileItem("Password: ********"),
                            Divider(color: Colors.black),
                            _buildProfileItem("Email: johndoe@gmail.com"),
                            Divider(color: Colors.black),
                            _buildProfileItem("Alamat: Jl. Mawar No. 5"),
                            Divider(color: Colors.black),
                            _buildProfileItem("Nomor Telepon: 081234567890"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Button di bawah Card box untuk update data profil
                  ElevatedButton(
                    onPressed: () {
                      // Aksi ketika button ditekan (misalnya membuka halaman update data)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Fitur Update Profil Sedang Dikembangkan")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      "Update Data Profil",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF9DC08D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                   SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF9DC08D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membuat item dalam Card box
  Widget _buildProfileItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }
}
