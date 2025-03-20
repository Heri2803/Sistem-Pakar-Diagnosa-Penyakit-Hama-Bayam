import 'package:flutter/material.dart';

class HasilDiagnosaPage extends StatelessWidget {
  final List<String> gejalaTerpilih;

  // Constructor untuk menerima data gejala dari halaman sebelumnya
  HasilDiagnosaPage({required this.gejalaTerpilih});

  // Data contoh untuk penyakit, hama, dan cara penanganan
  final Map<String, Map<String, String>> database = {
    "Daun berlubang": {
      "penyakit": "Ulat Grayak",
      "hama": "Ulat Daun",
      "penanganan": "Gunakan pestisida alami atau buatan untuk mengendalikan ulat daun."
    },
    "Daun kecoklatan": {
      "penyakit": "Karat Daun",
      "hama": "Kumbang Penggerek",
      "penanganan": "Semprotkan fungisida untuk karat daun dan gunakan perangkap kumbang."
    },
    "Tepi daun keriting": {
      "penyakit": "Virus Keriting",
      "hama": "Thrips",
      "penanganan": "Buang daun yang terinfeksi dan gunakan insektisida untuk mengendalikan thrips."
    },
  };

  @override
  Widget build(BuildContext context) {
    // Variabel untuk menghitung hasil berdasarkan gejala yang dipilih
    String namaPenyakit = "";
    String namaHama = "";
    String caraPenanganan = "";

    // Menentukan hasil berdasarkan gejala yang dipilih
    for (var gejala in gejalaTerpilih) {
      if (database.containsKey(gejala)) {
        namaPenyakit = database[gejala]?["penyakit"] ?? "";
        namaHama = database[gejala]?["hama"] ?? "";
        caraPenanganan = database[gejala]?["penanganan"] ?? "";
        break; // Mengambil data untuk gejala pertama yang cocok
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Hasil Diagnosa"),
        backgroundColor: Color(0xFF9DC08D),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama Penyakit dan Hama
                Text(
                  "Nama Penyakit: ${namaPenyakit.isNotEmpty ? namaPenyakit : "Tidak Diketahui"}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Nama Hama: ${namaHama.isNotEmpty ? namaHama : "Tidak Diketahui"}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Berdasarkan skor
                Text(
                  "Berdasarkan perhitungan skor yang telah dilakukan maka tanaman Anda terkena:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  namaPenyakit.isNotEmpty ? namaPenyakit : "Tidak Diketahui",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 20),

                // Cara Penanganan
                Text(
                  "Cara Penanganan:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  caraPenanganan.isNotEmpty
                      ? caraPenanganan
                      : "Tidak ada informasi penanganan yang tersedia.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
