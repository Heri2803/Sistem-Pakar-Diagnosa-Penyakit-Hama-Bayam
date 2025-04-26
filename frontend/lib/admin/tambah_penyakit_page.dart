import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';

class TambahPenyakitPage extends StatefulWidget {
  final VoidCallback onPenyakitAdded;

  TambahPenyakitPage({required this.onPenyakitAdded});

  @override
  _TambahPenyakitPageState createState() => _TambahPenyakitPageState();
}

class _TambahPenyakitPageState extends State<TambahPenyakitPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController penangananController = TextEditingController();
  final ApiService apiService = ApiService();

  @override
  void dispose() {
    namaController.dispose();
    deskripsiController.dispose();
    penangananController.dispose();
    super.dispose();
  }

  Future<void> _simpanPenyakit() async {
    if (namaController.text.isNotEmpty &&
        deskripsiController.text.isNotEmpty &&
        penangananController.text.isNotEmpty) {
      try {
        await apiService.createPenyakit(
          namaController.text,
          deskripsiController.text,
          penangananController.text,
        );
        widget.onPenyakitAdded();
        Navigator.pop(context);
        _showDialog('Berhasil', 'Data penyakit berhasil ditambahkan.');
      } catch (e) {
        _showDialog('Gagal', 'Gagal menambahkan data penyakit.');
        print("Error adding penyakit: $e");
      }
    } else {
      _showDialog('Error', 'Semua field harus diisi.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Penyakit Baru'),
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    width: 320, // atur lebar card box
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: namaController,
                          decoration: InputDecoration(labelText: 'Nama Penyakit'),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: deskripsiController,
                          decoration: InputDecoration(labelText: 'Deskripsi Penyakit'),
                          maxLines: 3, // Biar lebih panjang untuk deskripsi
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: penangananController,
                          decoration: InputDecoration(labelText: 'Penanganan Penyakit'),
                          maxLines: 3,
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30), // jarak antara card dan tombol
                ElevatedButton(
                  onPressed: _simpanPenyakit,
                  child: Text('Simpan Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[300], 
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
