import 'package:flutter/material.dart';

class DetailHamaPage extends StatelessWidget {
  final Map<String, dynamic> detailHama;

  const DetailHamaPage({required this.detailHama});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D),
      appBar: AppBar(
        backgroundColor: Color(0xFF9DC08D),
        title: Text(
          "Detail Hama",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (detailHama["gambar"] != null && detailHama["gambar"]!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    detailHama["gambar"]!,
                    height: 200,
                    width: 200, // Biar gambar full lebar
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 16),

              // Card Nama Hama
              SizedBox(
                width: double.infinity, // Bikin card full lebar
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nama Hama:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          detailHama["nama"] ?? "Nama hama tidak tersedia",
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
                width: double.infinity, // Bikin card full lebar
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Deskripsi:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          detailHama["deskripsi"] ?? "Deskripsi tidak tersedia",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Penanganan:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          detailHama["penanganan"] ?? "Penanganan tidak tersedia",
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
      ),
    );
  }
}
