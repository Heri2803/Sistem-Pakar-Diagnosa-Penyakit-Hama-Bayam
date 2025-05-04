import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'image_utilities_penyakit.dart';
 

class EditPenyakitPage extends StatefulWidget {
  final int idPenyakit;
  final String namaAwal;
  final String deskripsiAwal;
  final String penangananAwal;
  final String gambarUrl;
  final VoidCallback onPenyakitUpdated;

  const EditPenyakitPage({
    Key? key,
    required this.idPenyakit,
    required this.namaAwal,
    required this.deskripsiAwal,
    required this.penangananAwal,
    required this.gambarUrl,
    required this.onPenyakitUpdated,
  }) : super(key: key);

  @override
  _EditPenyakitPageState createState() => _EditPenyakitPageState();
}

class _EditPenyakitPageState extends State<EditPenyakitPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _penangananController = TextEditingController();
  final ApiService apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  XFile? _pickedFile;
  Uint8List? _webImage;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isImageLoading = false;
  Uint8List? _currentImageBytes;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.namaAwal;
    _deskripsiController.text = widget.deskripsiAwal;
    _penangananController.text = widget.penangananAwal;
    _loadExistingImage();
  }

  Future<void> _loadExistingImage() async {
    if (widget.gambarUrl.isEmpty) return;

    setState(() {
      _isImageLoading = true;
    });

    try {
      // Coba mengambil gambar langsung dari API
      final bytes = await apiService.getPenyakitImageBytes(widget.idPenyakit);
      
      if (bytes != null) {
        setState(() {
          _currentImageBytes = bytes;
          _isImageLoading = false;
        });
      } else {
        setState(() {
          _isImageLoading = false;
          _errorMessage = "Gagal memuat gambar dari server";
        });
      }
    } catch (e) {
      print("Error loading image: $e");
      setState(() {
        _isImageLoading = false;
        _errorMessage = "Error: $e";
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _penangananController.dispose();
    super.dispose();
  }

  Future<void> _updatePenyakit() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await apiService.updatePenyakit(
        widget.idPenyakit,
        _namaController.text,
        _deskripsiController.text,
        _penangananController.text,
        _pickedFile,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      widget.onPenyakitUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data penyakit berhasil diperbarui'))
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memperbarui data: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data: $e'))
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _pickedFile = pickedFile;
        print('Gambar dipilih: ${pickedFile.path}');

        // Baca file sebagai bytes untuk ditampilkan di UI
        final bytes = await pickedFile.readAsBytes();

        setState(() {
          _webImage = bytes;
          // Hapus referensi ke gambar lama
          _currentImageBytes = null;
        });
      } else {
        print('Tidak ada gambar dipilih');
      }
    } catch (e) {
      print('Error saat memilih gambar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e'))
      );
    }
  }

  Widget _buildImagePreview() {
    if (_isImageLoading) {
      return Container(
        height: 150,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_webImage != null) {
      // Tampilkan gambar yang baru dipilih
      return Column(
        children: [
          Image.memory(
            _webImage!,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying selected image: $error');
              return Text('Gagal memuat gambar yang dipilih');
            },
          ),
          SizedBox(height: 8),
          Text('Gambar baru dipilih', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      );
    } else if (_currentImageBytes != null) {
      // Tampilkan gambar yang diambil dari server
      return Column(
        children: [
          Image.memory(
            _currentImageBytes!,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying current image: $error');
              return Text('Gagal memuat gambar saat ini');
            },
          ),
          SizedBox(height: 8),
          Text('Gambar saat ini', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      );
    } else if (widget.idPenyakit > 0) {
      // Coba tampilkan gambar dari ID menggunakan komponen terpisah
      return Column(
        children: [
          ImageUtilitiesPenyakit.buildPenyakitImage(widget.idPenyakit, height: 150),
          SizedBox(height: 8),
          Text('Gambar saat ini', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      );
    } else {
      // Tampilkan placeholder
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('Tidak ada gambar tersedia'),
            ],
          ),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data Penyakit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(labelText: 'Nama Penyakit'),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _deskripsiController,
                      decoration: InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _penangananController,
                      decoration: InputDecoration(labelText: 'Penanganan'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                          'Foto Penyakit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildImagePreview(),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.photo_library),
                              label: Text('Pilih Gambar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                    ElevatedButton(
                      onPressed: _updatePenyakit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[300],
                      ),
                      child: Text(
                        'Simpan Perubahan',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
