import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart'; // Pastikan ini di-import ya

class EditPenyakitPage extends StatefulWidget {
  final int idPenyakit;
  final String namaAwal;
  final String deskripsiAwal;
  final String penangananAwal;
  final VoidCallback onPenyakitUpdated;

  const EditPenyakitPage({
    Key? key,
    required this.idPenyakit,
    required this.namaAwal,
    required this.deskripsiAwal,
    required this.penangananAwal,
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

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.namaAwal;
    _deskripsiController.text = widget.deskripsiAwal;
    _penangananController.text = widget.penangananAwal;
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
      await apiService.updatePenyakit(
        widget.idPenyakit,
        _namaController.text,
        _deskripsiController.text,
        _penangananController.text,
      );
      widget.onPenyakitUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data penyakit berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data: $e')),
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
