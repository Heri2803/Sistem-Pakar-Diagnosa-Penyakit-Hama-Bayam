import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';

class PenyakitPage extends StatefulWidget {
  @override
  _PenyakitPageState createState() => _PenyakitPageState();
}

class _PenyakitPageState extends State<PenyakitPage> {
   final ApiService apiService = ApiService();
  List<Map<String, dynamic>> penyakitList = [];

   @override
  void initState() {
    super.initState();
    _fetchPenyakit();
  }

  Future<void> _fetchPenyakit() async {
    try {
      List<Map<String, dynamic>> data = await apiService.getPenyakit();
      setState(() {
        penyakitList = data;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // 🔹 Hapus gejala dari API
  void _hapusPenyakit(int id) async {
    try {
      await apiService.deletePenyakit(id);
      _fetchPenyakit(); // Refresh data setelah hapus
    } catch (e) {
      print('Error hapus gejala: $e');
    }
  }

  void _konfirmasiHapus(int id) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus gejala ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup pop-up tanpa menghapus
            },
            child: Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup pop-up
              _hapusPenyakit(id); // Lanjutkan proses hapus
            },
            child: Text('Ya, Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    },
  );
}

  void _tambahPenyakit() {
    TextEditingController namaController = TextEditingController();
    TextEditingController penangananController = TextEditingController();
    TextEditingController deskripsiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Penyakit Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: deskripsiController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
              ),
              TextField(
                controller: penangananController,
                decoration: InputDecoration(labelText: 'Penanganan'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (namaController.text.isNotEmpty &&
                    deskripsiController.text.isNotEmpty &&
                    penangananController.text.isNotEmpty) {
                  try {
                    await apiService.createPenyakit(
                      namaController.text,
                      deskripsiController.text,
                      penangananController.text,
                    );
                    _fetchPenyakit();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error adding penyakit: $e");
                  }
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    ).then((_) {
      namaController.dispose();
      deskripsiController.dispose();
      penangananController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halaman Penyakit')),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: ElevatedButton(
                  onPressed: _tambahPenyakit, // Fungsi untuk menambah data penyakit
                  child: Text('Tambah Penyakit'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                child: DataTable(
                  columnSpacing: 5,
                  headingRowColor:
                      MaterialStateColor.resolveWith((states) => Colors.grey[300]!),
                  columns: [
                    DataColumn(label: SizedBox(width: 35, child: Text('No'))),
                    DataColumn(label: SizedBox(width: 50, child: Text('Kode'))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Nama'))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Deskripsi'))),
                    DataColumn(label: SizedBox(width: 100, child: Text('Penanganan'))),
                    DataColumn(label: SizedBox(width: 50, child: Text('Aksi'))),
                  ],
                  rows: penyakitList.map(
                    (penyakit) => DataRow(cells: [
                      DataCell(Text((penyakitList.indexOf(penyakit) + 1).toString())), // Nomor
                      DataCell(Text(penyakit['kode'] ?? '-')), // Kode Penyakit
                      DataCell(Text(penyakit['nama'] ?? '-')), // Nama Penyakit
                      DataCell(Text(penyakit['deskripsi'] ?? '-')), // Deskripsi
                      DataCell(Text(penyakit['penanganan'] ?? '-')), // Penanganan
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _konfirmasiHapus(penyakit['id']), // Hapus data
                        ),
                      ),
                    ]),
                  ).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
