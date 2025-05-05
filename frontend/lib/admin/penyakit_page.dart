import 'package:flutter/material.dart';
import 'package:frontend/admin/edit_penyakit_page.dart';
import 'package:frontend/api_services/api_services.dart';
import 'tambah_penyakit_page.dart';
import 'edit_penyakit_page.dart';

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

  //pagination
  int currentPage = 0;
  int rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    int start = currentPage * rowsPerPage;
    int end =
        (start + rowsPerPage < penyakitList.length)
            ? start + rowsPerPage
            : penyakitList.length;
    List currentPageData = penyakitList.sublist(start, end);
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TambahPenyakitPage(
                              onPenyakitAdded:
                                  _fetchPenyakit, // Panggil fungsi refresh setelah tambah
                            ),
                      ),
                    );
                  }, // Fungsi untuk menambah data penyakit
                  child: Text(
                    'Tambah Penyakit',
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
                        (penyakit) => DataRow(
                          cells: [
                            DataCell(
                              Text((penyakitList.indexOf(penyakit) + 1).toString()),
                            ),
                            DataCell(Text(penyakit['kode'] ?? '-')),
                            DataCell(Text(penyakit['nama'] ?? '-')),
                            DataCell(Text(penyakit['deskripsi'] ?? '-')),
                            DataCell(Text(penyakit['penanganan'] ?? '-')),
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
                                      if (penyakit['nilai_pakar'] != null) {
                                        // Coba parse jika string
                                        if (penyakit['nilai_pakar'] is String) {
                                          try {
                                            String nilaiStr =
                                                penyakit['nilai_pakar']
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
                                        else if (penyakit['nilai_pakar']
                                            is double) {
                                          nilaiPakar = penyakit['nilai_pakar'];
                                        }
                                        // Jika int, konversi ke double
                                        else if (penyakit['nilai_pakar'] is int) {
                                          nilaiPakar =
                                              penyakit['nilai_pakar'].toDouble();
                                        }
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => EditPenyakitPage(
                                                idPenyakit:
                                                    penyakit['id'], // pastikan 'hama' adalah Map dari API kamu
                                                namaAwal: penyakit['nama'] ?? '',
                                                deskripsiAwal:
                                                    penyakit['deskripsi'] ?? '',
                                                penangananAwal:
                                                    penyakit['penanganan'] ?? '',
                                                gambarUrl: 
                                                    penyakit['foto'] ?? '',
                                                nilai_pakar: nilaiPakar,
                                                onPenyakitUpdated:
                                                    _fetchPenyakit, // fungsi untuk refresh list setelah update
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed:
                                        () => _konfirmasiHapus(penyakit['id']),
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
                                                penyakitList.length
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
