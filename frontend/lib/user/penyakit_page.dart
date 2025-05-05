import 'package:flutter/material.dart';
import 'detail_penyakit_page.dart';
import 'package:frontend/api_services/api_services.dart';

class PenyakitPage extends StatefulWidget {
  @override
  _PenyakitPageState createState() => _PenyakitPageState();
}

class _PenyakitPageState extends State<PenyakitPage> {
  late Future<List<Map<String, dynamic>>> _penyakitListFuture;

  @override
  void initState() {
    super.initState();
    _penyakitListFuture = ApiService().getPenyakit();
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
              "Penyakit",
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
          future: _penyakitListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat data', style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Tidak ada data tersedia', style: TextStyle(color: Colors.white)));
            } else {
              final penyakitList = snapshot.data!;

              return ListView.builder(
                itemCount: penyakitList.length,
                itemBuilder: (context, index) {
                  final penyakit = penyakitList[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        penyakit["nama"] ?? "Tidak ada data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(penyakit["deskripsi"] ?? "Deskripsi tidak tersedia"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPenyakitPage(DetailPenyakit: penyakit),
                          ),
                        );
                      },
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
