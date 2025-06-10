import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // untuk File
import 'package:image_picker/image_picker.dart'; // untuk ImagePicker & ImageSource
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;


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
  final TextEditingController nilaiPakarController = TextEditingController();
  final ApiService apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _gambarUrl;
  // Untuk web
  Uint8List? _webImage;
  XFile? _pickedFile;

  @override
  void dispose() {
    namaController.dispose();
    deskripsiController.dispose();
    penangananController.dispose();
    nilaiPakarController.dispose();
    super.dispose();
  }

  Future<void> _simpanHama() async {
  if (namaController.text.isNotEmpty &&
      deskripsiController.text.isNotEmpty &&
      penangananController.text.isNotEmpty) {
    try {
      double? nilaipakar;
      if (nilaiPakarController.text.isNotEmpty) {
        String nilaiInput = nilaiPakarController.text.replaceAll(',', '.');
        nilaipakar = double.parse(nilaiInput);
      }

      await apiService.createHama(
        namaController.text,
        deskripsiController.text,
        penangananController.text,
        _pickedFile,
        nilaipakar, // boleh null
      );

      widget.onHamaAdded();
      Navigator.pop(context);
      _showDialog('Berhasil', 'Data hama berhasil ditambahkan.');
    } catch (e) {
      _showDialog('Gagal', 'Gagal menambahkan data hama.');
      print("Error adding hama: $e");
    }
  } else {
    _showDialog('Error', 'Semua field harus diisi (kecuali nilai pakar).');
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _pickedFile = pickedFile;
      print('Gambar dipilih: ${pickedFile.path}');
      
      // Baca file sebagai bytes untuk ditampilkan di web
      final bytes = await pickedFile.readAsBytes();
      
      setState(() {
        // Simpan data gambar sebagai bytes untuk ditampilkan
        _webImage = bytes;
        
        // Jika bukan di web, buat File object (untuk Android/iOS)
        if (!kIsWeb) {
          _imageFile = File(pickedFile.path);
        }
      });
    } else {
      print('Tidak ada gambar dipilih');
    }
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
                        // TextField(
                        //   controller: nilaiPakarController,
                        //   decoration: InputDecoration(labelText: 'Nilai Pakar'),
                        //   maxLines: 3,
                        // ),
                        SizedBox(height: 15),
                        Text('Foto'),
                    (_webImage != null)
                        ? Image.memory(
                          _webImage!,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error displaying image: $error');
                            return Text('Gagal memuat gambar');
                          },
                        )
                        : (_gambarUrl != null && _gambarUrl!.isNotEmpty)
                        ? Image.network(
                          _gambarUrl!,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading network image: $error');
                            return Text('Gagal memuat gambar dari server');
                          },
                        )
                        : Text('Tidak ada gambar tersedia'),
                        TextButton(
                      onPressed: _pickImage,
                      child: Text('Pilih Gambar'),
                    ),
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
