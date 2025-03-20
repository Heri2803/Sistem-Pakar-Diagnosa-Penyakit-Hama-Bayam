import 'package:flutter/material.dart';

class BasisPengetahuanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D), // Warna background halaman
      appBar: AppBar(
        backgroundColor: Color(0xFF9DC08D),
        elevation: 0, // Menghilangkan bayangan pada AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Warna putih
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: Text(
          "Basis Pengetahuan",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Memastikan judul tetap di tengah
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Menengahkan isi
          children: [
            // Button pertama
            ElevatedButton(
              onPressed: () {
                // Aksi untuk button pertama
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Membuat button kotak
                ),
                backgroundColor: Colors.white, // Warna button
                fixedSize: Size(250, 200), // Ukuran kotak button
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Menyesuaikan ukuran vertikal
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Caterpillar.png', // Path ke file asset
                    height: 80,
                    width: 80,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Hama Tanaman Bayam",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF9DC08D),
                      fontWeight: FontWeight.bold, // Warna teks
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Menambahkan lebih banyak jarak antar tombol

            // Button kedua
            ElevatedButton(
              onPressed: () {
                // Aksi untuk button kedua
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Membuat button kotak
                ),
                backgroundColor: Colors.white, // Warna button
                fixedSize: Size(250, 200), // Ukuran kotak button
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Menyesuaikan ukuran vertikal
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Virus.png', // Path ke file asset
                    height: 80,
                    width: 80,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Penyakit Tanaman Bayam",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF9DC08D),
                      fontWeight: FontWeight.bold, // Warna teks
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
