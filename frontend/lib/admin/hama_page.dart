import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';


class HamaPage extends StatefulWidget {
  @override
  _HamaPageState createState() => _HamaPageState();
}

class _HamaPageState extends State<HamaPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> hamaList = [];

  @override
  void initState() {
    super.initState();
    _fetchHama();
  }

  Future<void> _fetchHama() async {
    try {
      List<Map<String, dynamic>> data = await apiService.getHama();
      setState(() {
        hamaList = data;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // 🔹 Hapus gejala dari API
  void _hapusHama(int id) async {
    try {
      await apiService.deleteHama(id);
      _fetchHama(); // Refresh data setelah hapus
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
              _hapusHama(id); // Lanjutkan proses hapus
            },
            child: Text('Ya, Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    },
  );
}

  void _tambahHama() {
    TextEditingController namaController = TextEditingController();
    TextEditingController penangananController = TextEditingController();
    TextEditingController deskripsiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Hama Baru'),
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
                    await apiService.createHama(
                      namaController.text,
                      deskripsiController.text,
                      penangananController.text,
                    );
                    _fetchHama();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error adding hama: $e");
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
      appBar: AppBar(title: Text('Halaman Hama')),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: ElevatedButton(
                  onPressed: _tambahHama, // Fungsi untuk menambah data hama
                  child: Text('Tambah Hama'),
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
                  rows: hamaList.map(
                    (hama) => DataRow(cells: [
                      DataCell(Text((hamaList.indexOf(hama) + 1).toString())), // Nomor
                      DataCell(Text(hama['kode'] ?? '-')), // Kode Hama
                      DataCell(Text(hama['nama'] ?? '-')), // Nama Hama
                      DataCell(Text(hama['deskripsi'] ?? '-')), // Deskripsi
                      DataCell(Text(hama['penanganan'] ?? '-')), // Penanganan
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _konfirmasiHapus(hama['id']), // Hapus data
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
