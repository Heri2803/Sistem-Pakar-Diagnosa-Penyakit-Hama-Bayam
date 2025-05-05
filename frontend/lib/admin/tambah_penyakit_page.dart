import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // untuk File
import 'package:image_picker/image_picker.dart'; // untuk ImagePicker & ImageSource
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

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

  Future<void> _simpanPenyakit() async {
    if (namaController.text.isNotEmpty &&
        deskripsiController.text.isNotEmpty &&
        penangananController.text.isNotEmpty &&
        nilaiPakarController.text.isNotEmpty) {
      try {
        String nilaiInput = nilaiPakarController.text.replaceAll(',', '.');
        double nilaiPakar = double.parse(nilaiInput);
        await apiService.createPenyakit(
          namaController.text,
          deskripsiController.text,
          penangananController.text,
          _pickedFile,
          nilaiPakar,
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
                        TextField(
                          controller: nilaiPakarController,
                          decoration: InputDecoration(labelText: 'nilai pakar'),
                          maxLines: 3,
                        ),
                        SizedBox(height: 15),
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
