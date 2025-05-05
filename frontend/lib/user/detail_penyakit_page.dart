import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';
import 'dart:typed_data';

class DetailPenyakitPage extends StatefulWidget {
  final Map<String, dynamic> DetailPenyakit;
  final int? penyakitId;

  const DetailPenyakitPage({Key? key, required this.DetailPenyakit, this.penyakitId})
    : super(key: key);

  @override
  _DetailPenyakitPageState createState() => _DetailPenyakitPageState();
}

class _DetailPenyakitPageState extends State<DetailPenyakitPage> {
  late Future<Map<String, dynamic>> _detailPenyakitFuture;
  late Map<String, dynamic> _currentDetailPenyakit;

  @override
  void initState() {
    super.initState();
    _currentDetailPenyakit = widget.DetailPenyakit;

    // Jika hamaId tersedia, fetch data terbaru dari API
    if (widget.penyakitId != null) {
      _detailPenyakitFuture = _fetchDetailPenyakit(widget.penyakitId!);
    } else {
      // Jika tidak ada ID, gunakan data yang sudah diberikan
      _detailPenyakitFuture = Future.value(widget.DetailPenyakit);
    }
  }

  Future<Map<String, dynamic>> _fetchDetailPenyakit(int id) async {
    try {
      final detailData = await ApiService().getPenyakitById(id);
      setState(() {
        _currentDetailPenyakit = detailData;
      });
      return detailData;
    } catch (e) {
      print('Error fetching detail penyakit: $e');
      // Jika gagal fetch, gunakan data yang sudah ada
      return widget.DetailPenyakit;
    }
  }

  // Fungsi untuk memvalidasi URL gambar
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    // Periksa apakah URL berakhir dengan ekstensi gambar yang umum
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  // Widget untuk menampilkan gambar dengan penanganan error yang lebih baik
  Widget _buildImageWidget(String? filename) {
    if (filename == null || filename.isEmpty) {
      return _buildPlaceholderImage(
        "Tidak ada gambar tersedia",
        Icons.image_not_supported,
      );
    }

    return FutureBuilder<Uint8List?>(
      future: ApiService().getPenyakitImageBytesByFilename(filename),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 200,
            width: double.infinity,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return _buildPlaceholderImage(
            "Gagal memuat gambar",
            Icons.broken_image,
          );
        } else {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              snapshot.data!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.contain, // untuk memastikan proporsional & penuh
            ),
          );
        }
      },
    );
  }

  // Widget untuk placeholder gambar
  Widget _buildPlaceholderImage(String message, IconData icon) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[600]),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D),
      appBar: AppBar(
        backgroundColor: Color(0xFF9DC08D),
        title: Text("Detail Penyakit", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailPenyakitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            // Tampilkan data yang sudah ada jika terjadi error
            return _buildDetailContent(_currentDetailPenyakit);
          }
          print("Snapshot data runtimeType: ${snapshot.data.runtimeType}");
          print("Snapshot data content: ${snapshot.data}");

          // Jika berhasil fetch data baru, tampilkan data tersebut
          final detailData = snapshot.data ?? _currentDetailPenyakit;
          return _buildDetailContent(detailData);
        },
      ),
    );
  }

  Widget _buildDetailContent(Map<String, dynamic> detailData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tampilkan foto dari database dengan penanganan error yang lebih baik
            _buildImageWidget(detailData["foto"]),
            SizedBox(height: 16),

            // Card Nama Hama
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nama Penyakit:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        detailData["nama"] ?? "Nama hama tidak tersedia",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Card Deskripsi + Penanganan
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Deskripsi:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        detailData["deskripsi"] ?? "Deskripsi tidak tersedia",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Penanganan:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        detailData["penanganan"] ?? "Penanganan tidak tersedia",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
