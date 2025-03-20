import 'package:flutter/material.dart';

class ProfilPakarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D),
      body: Stack(
        children: [
          // Judul halaman
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0), // Jarak dari atas
              child: Text(
                "Profil Pakar",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
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
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Foto profil berbentuk bulat
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/expert_photo.jpg'), // Ganti dengan path foto Anda
                    ),
                    SizedBox(height: 16),

                    // Nama pakar
                    Text(
                      "Dr. John Doe",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),

                    // Profesi pakar
                    Text(
                      "Ahli Pertanian dan Hama Tanaman",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
