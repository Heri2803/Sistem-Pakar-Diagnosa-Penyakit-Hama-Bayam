import 'package:flutter/material.dart';
import 'detail_hama_page.dart';

class HamaPage extends StatelessWidget {
  final List<Map<String, String>> hamaList = [
    {
      "nama hama": "Karat Putih",
      "deskripsi": "Penyakit yang umum pada bayam.",
      "penanganan": "Gunakan fungisida sesuai anjuran dan potong daun yang terinfeksi.",
      "gambar": "assets/images/karat putih.jpeg",
    },
    {
      "nama hama": "Virus Keriting",
      "deskripsi": "Disebabkan oleh infeksi virus.",
      "penanganan": "Musnahkan tanaman terinfeksi dan kontrol vektor seperti kutu daun.",
      "gambar": "assets/images/virus_keriting.jpeg",
    },
    {
      "nama hama": "Kekurangan Mangan",
      "deskripsi": "Kekurangan unsur hara mikro.",
      "penanganan": "Tambahkan pupuk yang mengandung mangan (Mn).",
      "gambar": "assets/images/kekurangan_mangan.jpeg",
    },
    {
      "nama hama": "Downy Mildew",
      "deskripsi": "Penyakit jamur pada bayam.",
      "penanganan": "Gunakan fungisida berbahan aktif metalaxyl dan perbaiki drainase tanah.",
      "gambar": "assets/images/downy_mildew.jpeg",
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
            padding: const EdgeInsets.only(right: 30),
            child: Text(
              "Hama",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
                itemCount: hamaList.length,
                itemBuilder: (context, index) {
                  final diagnosa = hamaList[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        diagnosa["nama hama"] ?? "Tidak ada data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(diagnosa["deskripsi"] ?? "Deskripsi tidak tersedia"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailHamaPage(detailRiwayat: diagnosa),
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