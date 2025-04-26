import 'package:flutter/material.dart';
import 'package:frontend/user/profile_pakar_page.dart';
import 'diagnosa_page.dart';
import 'riwayat_diagnosa_page.dart';
import 'profile_page.dart';
import 'basis_pengetahuan_page.dart';


class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9DC08D), // Warna latar belakang #9DC08D
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Text(
              "Sistem Pakar Diagnosa Penyakit dan Hama Pada Bayam",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20), // Jarak antara judul dan gambar

          Image.asset(
            'assets/images/bayam.png', // Ubah sesuai path gambar
            width: 120, // Ukuran gambar
            height: 120,
          ),

          const SizedBox(height: 10), // Jarak antara gambar dan button utama

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity, // Lebar memenuhi layar (horizontal)
              height: 60, // Tinggi button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Sudut melengkung
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiagnosaPage(),
                    ), // Perbaikan di sini
                  );
                },
                child: const Text(
                  "Mulai Diagnosa",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ), // Jarak antara tombol utama dan grid button

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 20, // Jarak horizontal antar tombol
              runSpacing: 20, // Jarak vertikal antar baris tombol
              alignment: WrapAlignment.center, // Menempatkan tombol di tengah
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonMenu(
                      title: "Riwayat Diagnosa",
                      customIcon: Image.asset(
                        'assets/images/Order History.png',
                        width: 48,
                        height: 48,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RiwayatDiagnosaPage(),
                          ), // Perbaikan di sini
                        );
                      },
                    ),
                    ButtonMenu(
                      title: "Profile",
                      customIcon: Image.asset(
                    'assets/images/Test Account.png',
                    width: 48,
                    height: 48,
                  ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilPage(),
                          ), // Perbaikan di sini
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20), // Jarak antar tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                            builder: (context) => BasisPengetahuanPage(),
                          ), // Perbaikan di sini
                        );
                      },
                    ),
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
                          MaterialPageRoute(
                            builder: (context) => ProfilPakarPage(),
                          ), // Perbaikan di sini
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30), // Ruang di bawah tombol terakhir
        ],
      ),
    );
  }
}

// Widget untuk tombol menu
class ButtonMenu extends StatelessWidget {
  final String title;
  final Widget customIcon;
  final VoidCallback onTap;

  const ButtonMenu({
    required this.title,
    required this.customIcon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customIcon, 
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
