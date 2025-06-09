import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
import 'dart:typed_data';

class DetailRiwayatPage extends StatelessWidget {
  final Map<String, dynamic> detailRiwayat;
  final ApiService apiService = ApiService();

  DetailRiwayatPage({required this.detailRiwayat}) {
    print("Detail Riwayat Data: $detailRiwayat");
  }

  Future<Map<String, dynamic>> fetchDetailData() async {
    final diagnosisType = detailRiwayat['diagnosis_type'];
    final diagnosisName = detailRiwayat['diagnosis'];

    print("Diagnosis Type: $diagnosisType, Name: $diagnosisName");

    try {
      if (diagnosisType == 'penyakit') {
        // Dapatkan daftar semua penyakit
        final penyakitList = await apiService.getPenyakit();
        // Cari penyakit berdasarkan nama
        final penyakit = penyakitList.firstWhere(
          (p) =>
              p['nama'].toString().toLowerCase() ==
              diagnosisName.toString().toLowerCase(),
          orElse: () => throw Exception('Penyakit tidak ditemukan'),
        );

        final id = penyakit['id'];
        print("Found Penyakit ID: $id");

        // Ambil gambar jika ID ditemukan
        final imageBytes =
            id != null ? await apiService.getPenyakitImageBytes(id) : null;

        return {...penyakit, 'imageBytes': imageBytes};
      } else if (diagnosisType == 'hama') {
        // Dapatkan daftar semua hama
        final hamaList = await apiService.getHama();
        // Cari hama berdasarkan nama
        final hama = hamaList.firstWhere(
          (h) =>
              h['nama'].toString().toLowerCase() ==
              diagnosisName.toString().toLowerCase(),
          orElse: () => throw Exception('Hama tidak ditemukan'),
        );

        final id = hama['id'];
        print("Found Hama ID: $id");

        // Ambil gambar jika ID ditemukan
        final imageBytes =
            id != null ? await apiService.getHamaImageBytes(id) : null;

        return {...hama, 'imageBytes': imageBytes};
      } else {
        throw Exception('Tipe diagnosis tidak valid');
      }
    } catch (e) {
      print("Error in fetchDetailData: $e");
      throw Exception("Gagal mengambil detail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final gejalaList = (detailRiwayat['gejala'] as List).join(', ');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9DC08D),
        title: Text(
          'Detail Riwayat Diagnosa',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetailData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Data tidak ditemukan"));
          }

          final detailData = snapshot.data!;
          final imageBytes = detailData['imageBytes'] as Uint8List?;
          final deskripsi =
              detailData['deskripsi'] ?? 'Deskripsi tidak tersedia';
          final penanganan =
              detailData['penanganan'] ?? 'Penanganan tidak tersedia';

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosis: ${detailRiwayat['diagnosis']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (imageBytes != null)
                      // Ganti bagian Container untuk gambar dengan kode berikut
                      if (imageBytes != null)
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxHeight: 250, // Tinggi maksimal yang konsisten
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                Colors
                                    .grey[200], // Warna background untuk area gambar
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              // Menambahkan Center widget
                              child: AspectRatio(
                                aspectRatio:
                                    16 / 9, // Rasio aspek yang konsisten
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(imageBytes),
                                      fit:
                                          BoxFit
                                              .contain, // Menggunakan contain untuk menjaga aspek rasio
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    SizedBox(height: 12),
                    Text('Gejala: $gejalaList', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      'Hasil: ${detailRiwayat['hasil'] != null ? "${(((detailRiwayat['hasil'] as num) * 1000).floor() / 10).toStringAsFixed(1)}%" : "-"}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tanggal: ${detailRiwayat['tanggal_diagnosa'] ?? "-"}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Deskripsi:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(deskripsi, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text(
                      'Penanganan:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(penanganan, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
