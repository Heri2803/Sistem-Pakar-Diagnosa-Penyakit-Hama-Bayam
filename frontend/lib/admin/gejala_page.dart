import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart'; // Pastikan file ini sesuai

class GejalaPage extends StatefulWidget {
  @override
  _GejalaPageState createState() => _GejalaPageState();
}

class _GejalaPageState extends State<GejalaPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> gejalaList = [];

  @override
  void initState() {
    super.initState();
    fetchGejala();
  }
  

  // 🔹 Ambil data gejala dari API
  Future<void> fetchGejala() async {
    try {
      final data = await apiService.getGejala();
      setState(() {
        gejalaList = data;
      });
    } catch (e) {
      print('Error fetching gejala: $e');
    }
  }

  // 🔹 Tambah gejala baru ke API
  void _tambahGejala() {
    TextEditingController namaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Gejala Baru'),
          content: TextField(
            controller: namaController,
            decoration: InputDecoration(labelText: 'Nama'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (namaController.text.isNotEmpty) {
                  try {
                    await apiService.createGejala(namaController.text);
                    Navigator.pop(context);
                    fetchGejala(); // Refresh data setelah tambah
                  } catch (e) {
                    print('Error tambah gejala: $e');
                  }
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Hapus gejala dari API
  void _hapusGejala(int id) async {
    try {
      await apiService.deleteGejala(id);
      fetchGejala(); // Refresh data setelah hapus
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
              _hapusGejala(id); // Lanjutkan proses hapus
            },
            child: Text('Ya, Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halaman Gejala')),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: ElevatedButton(
                  onPressed: _tambahGejala,
                  child: Text('Tambah Gejala'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey[300]!),
                  columns: [
                    DataColumn(label: SizedBox(width: 50, child: Text('No'))),
                    DataColumn(label: SizedBox(width: 80, child: Text('Kode'))),
                    DataColumn(label: SizedBox(width: 150, child: Text('Nama'))),
                    DataColumn(label: SizedBox(width: 80, child: Text('Aksi'))),
                  ],
                  rows: gejalaList.map(
                    (gejala) => DataRow(cells: [
                      DataCell(Text((gejalaList.indexOf(gejala) + 1).toString())), // Nomor
                      DataCell(Text(gejala['kode'])), // Kode Gejala
                      DataCell(Text(gejala['nama'])), // Nama Gejala
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _konfirmasiHapus(gejala['id']), // Hapus data
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
