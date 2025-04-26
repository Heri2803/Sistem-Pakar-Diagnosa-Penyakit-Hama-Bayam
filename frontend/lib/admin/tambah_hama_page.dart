import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';

class TambahHamaPage extends StatefulWidget {
  final VoidCallback onHamaAdded;

  TambahHamaPage({required this.onHamaAdded});

  @override
  _TambahHamaPageState createState() => _TambahHamaPageState();
}

class _TambahHamaPageState extends State<TambahHamaPage> {
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

  Future<void> _simpanHama() async {
    if (namaController.text.isNotEmpty &&
        deskripsiController.text.isNotEmpty &&
        penangananController.text.isNotEmpty) {
      try {
        await apiService.createHama(
          namaController.text,
          deskripsiController.text,
          penangananController.text,
        );
        widget.onHamaAdded();
        Navigator.pop(context);
        _showDialog('Berhasil', 'Data hama berhasil ditambahkan.');
      } catch (e) {
        _showDialog('Gagal', 'Gagal menambahkan data hama.');
        print("Error adding hama: $e");
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
        title: Text('Tambah Hama Baru'),
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
                          decoration: InputDecoration(labelText: 'Nama Hama'),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: deskripsiController,
                          decoration: InputDecoration(labelText: 'Deskripsi Hama'),
                          maxLines: 3, // Biar lebih panjang untuk deskripsi
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: penangananController,
                          decoration: InputDecoration(labelText: 'Penanganan Hama'),
                          maxLines: 3,
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30), // jarak antara card dan tombol
                ElevatedButton(
                  onPressed: _simpanHama,
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
