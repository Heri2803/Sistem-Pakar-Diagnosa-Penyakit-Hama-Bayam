import 'package:flutter/material.dart';
import 'detail_hama_page.dart';
import 'package:frontend/api_services/api_services.dart';

class HamaPage extends StatefulWidget {
  @override
  _HamaPageState createState() => _HamaPageState();
}

class _HamaPageState extends State<HamaPage> {
  late Future<List<Map<String, dynamic>>> _hamaListFuture;

  @override
  void initState() {
    super.initState();
    _hamaListFuture = _fetchHamaData();
  }
  
  // Fungsi untuk mengambil dan memproses data hama
  Future<List<Map<String, dynamic>>> _fetchHamaData() async {
    try {
      // Mengambil data dari API
      final hamaList = await ApiService().getHama();
      
      // Data sudah lengkap dengan URL foto dari backend
      return hamaList;
    } catch (e) {
      print('Error fetching hama data: $e');
      throw e;
    }
  }

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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _hamaListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat data', style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Tidak ada data tersedia', style: TextStyle(color: Colors.white)));
            } else {
              final hamaList = snapshot.data!;

              return ListView.builder(
                itemCount: hamaList.length,
                itemBuilder: (context, index) {
                  final hama = hamaList[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Navigasi ke halaman detail dengan ID dan data awal
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailHamaPage(
                              detailHama: hama,
                              hamaId: hama["id"], // Kirim ID untuk fetch data detil
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Informasi hama
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hama["nama"] ?? "Tidak ada data",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    hama["deskripsi"] ?? "Deskripsi tidak tersedia",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Icon panah ke kanan
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}