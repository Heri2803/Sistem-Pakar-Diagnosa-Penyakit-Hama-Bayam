import 'package:flutter/material.dart';
import 'login_page.dart';
import 'basis_pengetahuan_page.dart';
import 'profile_pakar_page.dart';

class BeforeLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D), // Warna latar belakang #9DC08D
      body: Column(
        children: [
          // Nama Aplikasi di Tengah Atas
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              children: [
                Text(
                  "Sistem Pakar Diagnosa",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:
                        20, // Ukuran font lebih besar untuk kalimat pertama
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Penyakit Dan Hama Tanaman Bayam",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20, // Ukuran font lebih kecil untuk kalimat kedua
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 80), // Jarak antara judul dan gambar

          // Gambar di atas button persegi panjang
          Image.asset(
            'assets/images/bayam.png', // Ubah sesuai path gambar
            width: 140, // Ukuran gambar
            height: 140,
          ),

          SizedBox(
              height: 100), // Jarak antara gambar dan button persegi panjang

          // Button Persegi Panjang dengan Sudut Melengkung
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Warna tombol
                  foregroundColor: Colors.green, // Warna teks
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Sudut melengkung
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  ); // Mengarahkan ke halaman login
                },
                child: Text(
                  "Mulai Diagnosa",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          SizedBox(
              height:
                  35), // Jarak antara button persegi panjang dan tombol bawah

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 20, // Jarak horizontal antar tombol
              runSpacing: 20, // Jarak vertikal antar baris tombol
              alignment: WrapAlignment.center, // Menempatkan tombol di tengah
              children: [
                ButtonMenu(
                  title: "Info Pakar",
                  customIcon: Image.asset(
                    'assets/images/Businessman.png',
                    width: 48,
                    height: 48,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilPakarPage()),
                    );
                  },
                ),
                ButtonMenu(
                  title: "Basis Pengetahuan",
                  customIcon: Image.asset(
                    'assets/images/Literature.png',
                    width: 48,
                    height: 48,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BasisPengetahuanPage()),
                    );
                  },
                ),
              ],
            ),
          ),

          Spacer(), // Memberi ruang di bawah tombol
        ],
      ),
    );
  }
}

class ButtonMenu extends StatelessWidget {
  final String title;
  final Widget customIcon; // Ikon kustom sebagai widget
  final VoidCallback onTap;

  ButtonMenu(
      {required this.title, required this.customIcon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, // Ukuran tombol agar seimbang
      height: 100, // Tinggi tombol lebih besar
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Warna tombol putih
          foregroundColor: Colors.green, // Warna teks hijau
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Sudut sedikit melengkung
          ),
        ),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Pusatkan konten secara vertikal
          children: [
            customIcon, // Ikon kustom
            SizedBox(
                height:
                    0), // Jarak antara ikon dan teks (dapat diubah sesuai kebutuhan)
            Text(
              title,
              textAlign: TextAlign.center, // Teks berada di tengah
              style: TextStyle(
                fontSize: 14, // Ukuran teks
                fontWeight: FontWeight.bold, // Teks tebal
                color: Colors
                    .green, // Warna teks hijau (konsisten dengan foregroundColor)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
