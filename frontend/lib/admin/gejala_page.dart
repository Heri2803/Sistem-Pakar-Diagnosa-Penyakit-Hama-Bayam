import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart'; // Pastikan file ini sesuai

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
  
  void showEditDialog(BuildContext context, Map<String, dynamic> gejala) {
  final TextEditingController editNamaController = TextEditingController(text: gejala['nama'] ?? '');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Edit Hama',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editNamaController,
              decoration: InputDecoration(
                labelText: 'Nama',
              ),
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
              try {
                await apiService.updateGejala(
                  gejala['id'],
                  editNamaController.text
                );
                fetchGejala();
                Navigator.pop(context);
              } catch (e) {
                print("Error updating gejala: $e");
              }
            },
            child: Text('Simpan', style: TextStyle(color: Colors.black)),
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



//pagination
  int currentPage = 0;
  int rowsPerPage = 10;

  @override
Widget build(BuildContext context) {
  int start = currentPage * rowsPerPage;
  int end = (start + rowsPerPage < gejalaList.length)
      ? start + rowsPerPage
      : gejalaList.length;
  List currentPageData = gejalaList.sublist(start, end);

  return Scaffold(
    appBar: AppBar(
      title: Text('Halaman Gejala'),
    ),
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
                child: Text(
                  'Tambah Gejala',
                  style: TextStyle(color: Colors.green[200]),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => const Color(0xFF9DC08D),
                  ),
                  columns: [
                    DataColumn(label: SizedBox(width: 35, child: Text('No'))),
                    DataColumn(label: SizedBox(width: 80, child: Text('Kode'))),
                    DataColumn(label: SizedBox(width: 150, child: Text('Nama'))),
                    DataColumn(label: SizedBox(width: 80, child: Text('Aksi'))),
                  ],
                  rows: [
                    ...currentPageData.map(
                      (gejala) => DataRow(
                        cells: [
                          DataCell(Text((gejalaList.indexOf(gejala) + 1).toString())),
                          DataCell(Text(gejala['kode'] ?? '-')),
                          DataCell(Text(gejala['nama'] ?? '-')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Color(0xFF9DC08D)),
                                  onPressed: () => showEditDialog(context, gejala),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _konfirmasiHapus(gejala['id']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataRow(
                      cells: [
                        DataCell(Container()),
                        DataCell(Container()),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.chevron_left),
                                  onPressed: currentPage > 0
                                      ? () => setState(() => currentPage--)
                                      : null,
                                ),
                                Text(' ${currentPage + 1}'),
                                IconButton(
                                  icon: Icon(Icons.chevron_right),
                                  onPressed:
                                      (currentPage + 1) * rowsPerPage < gejalaList.length
                                          ? () => setState(() => currentPage++)
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(Container()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
