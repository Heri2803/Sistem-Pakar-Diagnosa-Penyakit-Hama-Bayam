import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';
import 'tambah_hama_page.dart';
import 'edit_hama_page.dart';

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

  //pagination
  int currentPage = 0;
  int rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    int start = currentPage * rowsPerPage;
    int end =
        (start + rowsPerPage < hamaList.length)
            ? start + rowsPerPage
            : hamaList.length;
    List currentPageData = hamaList.sublist(start, end);
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TambahHamaPage(
                              onHamaAdded:
                                  _fetchHama, // Panggil fungsi refresh setelah tambah
                            ),
                      ),
                    );
                  },
                  child: Text(
                    'Tambah Hama',
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
                      DataColumn(
                        label: SizedBox(width: 50, child: Text('Kode')),
                      ),
                      DataColumn(
                        label: SizedBox(width: 100, child: Text('Nama')),
                      ),
                      DataColumn(
                        label: SizedBox(width: 100, child: Text('Deskripsi')),
                      ),
                      DataColumn(
                        label: SizedBox(width: 100, child: Text('Penanganan')),
                      ),
                      DataColumn(
                        label: SizedBox(width: 50, child: Text('Aksi')),
                      ),
                    ],
                    rows: [
                      ...currentPageData.map(
                        (hama) => DataRow(
                          cells: [
                            DataCell(
                              Text((hamaList.indexOf(hama) + 1).toString()),
                            ),
                            DataCell(Text(hama['kode'] ?? '-')),
                            DataCell(Text(hama['nama'] ?? '-')),
                            DataCell(Text(hama['deskripsi'] ?? '-')),
                            DataCell(Text(hama['penanganan'] ?? '-')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Color(0xFF9DC08D),
                                    ),
                                    onPressed: () {
                                      // Parse nilai_pakar dengan aman
                                      double nilaiPakar = 0.0;
                                      if (hama['nilai_pakar'] != null) {
                                        // Coba parse jika string
                                        if (hama['nilai_pakar'] is String) {
                                          try {
                                            String nilaiStr =
                                                hama['nilai_pakar']
                                                    .toString()
                                                    .trim();
                                            if (nilaiStr.isNotEmpty) {
                                              nilaiPakar = double.parse(
                                                nilaiStr.replaceAll(',', '.'),
                                              );
                                            }
                                          } catch (e) {
                                            print(
                                              "Error parsing nilai_pakar: $e",
                                            );
                                          }
                                        }
                                        // Langsung gunakan jika sudah double
                                        else if (hama['nilai_pakar']
                                            is double) {
                                          nilaiPakar = hama['nilai_pakar'];
                                        }
                                        // Jika int, konversi ke double
                                        else if (hama['nilai_pakar'] is int) {
                                          nilaiPakar =
                                              hama['nilai_pakar'].toDouble();
                                        }
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EditHamaPage(
                                                idHama:
                                                    hama['id'], // pastikan 'hama' adalah Map dari API kamu
                                                namaAwal: hama['nama'] ?? '',
                                                deskripsiAwal:
                                                    hama['deskripsi'] ?? '',
                                                penangananAwal:
                                                    hama['penanganan'] ?? '',
                                                gambarUrl: hama['foto'] ?? '',
                                                nilai_pakar: nilaiPakar,
                                                onHamaUpdated:
                                                    _fetchHama, // fungsi untuk refresh list setelah update
                                              ),
                                        ),
                                      );
                                    },
                                  ),

                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed:
                                        () => _konfirmasiHapus(hama['id']),
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
                                    onPressed:
                                        currentPage > 0
                                            ? () =>
                                                setState(() => currentPage--)
                                            : null,
                                  ),
                                  Text(' ${currentPage + 1}'),
                                  IconButton(
                                    icon: Icon(Icons.chevron_right),
                                    onPressed:
                                        (currentPage + 1) * rowsPerPage <
                                                hamaList.length
                                            ? () =>
                                                setState(() => currentPage++)
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Container()),
                          DataCell(Container()),
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
