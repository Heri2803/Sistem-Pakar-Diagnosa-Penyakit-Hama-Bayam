import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart'; // Pastikan ini di-import ya

class EditHamaPage extends StatefulWidget {
  final int idHama;
  final String namaAwal;
  final String deskripsiAwal;
  final String penangananAwal;
  final VoidCallback onHamaUpdated;

  const EditHamaPage({
    Key? key,
    required this.idHama,
    required this.namaAwal,
    required this.deskripsiAwal,
    required this.penangananAwal,
    required this.onHamaUpdated,
  }) : super(key: key);

  @override
  _EditHamaPageState createState() => _EditHamaPageState();
}

class _EditHamaPageState extends State<EditHamaPage> {
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

  Future<void> _updateHama() async {
    try {
      await apiService.updateHama(
        widget.idHama,
        _namaController.text,
        _deskripsiController.text,
        _penangananController.text,
      );
      widget.onHamaUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data hama berhasil diperbarui')),
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
        title: Text('Edit Data Hama'),
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
                      decoration: InputDecoration(labelText: 'Nama Hama'),
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
                      onPressed: _updateHama,
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
