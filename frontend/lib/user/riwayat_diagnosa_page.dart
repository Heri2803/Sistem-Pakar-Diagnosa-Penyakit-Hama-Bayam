import 'package:flutter/material.dart';

class RiwayatDiagnosaPage extends StatelessWidget {
  final List<Map<String, String>> diagnosaList = [
    {
      "nama": "Karat Putih",
      "deskripsi": "Penyakit yang umum pada bayam.",
      "penyakit": "Karat Putih",
      "hama": "Tidak ada hama spesifik",
      "penanganan": "Gunakan fungisida sesuai anjuran dan potong daun yang terinfeksi.",
      "gambar": "assets/images/karat putih.jpeg",
    },
    {
      "nama": "Virus Keriting",
      "deskripsi": "Disebabkan oleh infeksi virus.",
      "penyakit": "Virus Keriting",
      "hama": "Tidak ada hama spesifik",
      "penanganan": "Musnahkan tanaman terinfeksi dan kontrol vektor seperti kutu daun."
    },
    {
      "nama": "Kekurangan Mangan",
      "deskripsi": "Kekurangan unsur hara mikro.",
      "penyakit": "Kekurangan Mangan",
      "hama": "Tidak ada hama spesifik",
      "penanganan": "Tambahkan pupuk yang mengandung mangan (Mn)."
    },
    {
      "nama": "Downy Mildew",
      "deskripsi": "Penyakit jamur pada bayam.",
      "penyakit": "Downy Mildew",
      "hama": "Tidak ada hama spesifik",
      "penanganan": "Gunakan fungisida berbahan aktif metalaxyl dan perbaiki drainase tanah."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D),
      appBar: AppBar(
        backgroundColor: Color(0xFF9DC08D),
        title: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(right: 30), // Geser ke kiri
            child: Text(
              "Riwayat Diagnosa",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:  Colors.white),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: diagnosaList.length,
                itemBuilder: (context, index) {
                  final diagnosa = diagnosaList[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        diagnosa["nama"] ?? "Tidak ada data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(diagnosa["deskripsi"] ?? "Deskripsi tidak tersedia"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailRiwayatPage(
                              detailRiwayat: {
                                "penyakit": diagnosa["penyakit"] ?? "",
                                "hama": diagnosa["hama"] ?? "",
                                "penanganan": diagnosa["penanganan"] ?? "",
                                "gambar": diagnosa["gambar"] ?? "",
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRiwayatPage extends StatelessWidget {
  final Map<String, String> detailRiwayat;

  DetailRiwayatPage({required this.detailRiwayat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D),
      appBar: AppBar(
        backgroundColor: Color(0xFF9DC08D),
        title: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(right: 30),
            child: Text(
              "Hasil Diagnosa",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (detailRiwayat['gambar'] != null) 
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  detailRiwayat['gambar']!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama Penyakit: ${detailRiwayat['penyakit']}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Nama Hama: ${detailRiwayat['hama']}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cara Penanganan:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text(
                      detailRiwayat['penanganan'] ?? "Data tidak tersedia",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}