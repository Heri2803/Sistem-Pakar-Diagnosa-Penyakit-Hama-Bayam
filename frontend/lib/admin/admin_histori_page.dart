import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';
import 'package:intl/intl.dart';

class AdminHistoriPage extends StatefulWidget {
  @override
  _AdminHistoriPageState createState() => _AdminHistoriPageState();
}

class _AdminHistoriPageState extends State<AdminHistoriPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> historiData = [];
  List<Map<String, dynamic>> groupedHistoriData = [];
  bool isLoading = true;
  String? error;

  // Pagination variables
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int _totalPages = 0;
  List<Map<String, dynamic>> _currentPageData = [];

  @override
  void initState() {
    super.initState();
    _loadHistoriData();
  }

  Future<void> _loadHistoriData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Dapatkan semua histori terlebih dahulu
      final allHistori = await apiService.getAllHistori();

      // Kumpulkan semua hasil fetchHistoriDenganDetail untuk setiap user
      List<Map<String, dynamic>> detailedHistori = [];
      for (var histori in allHistori) {
        if (histori['userId'] != null) {
          final userHistori = await apiService.fetchHistoriDenganDetail(
            histori['userId'].toString(),
          );
          detailedHistori.addAll(userHistori);
        }
      }

      // Kelompokkan data berdasarkan user, diagnosa, dan waktu yang sama
      final groupedData = _groupHistoriData(detailedHistori);

      setState(() {
        historiData = detailedHistori; // Simpan data asli jika perlu
        groupedHistoriData = groupedData; // Data yang sudah dikelompokkan
        _updatePagination(0); // Set halaman pertama
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mengelompokkan data berdasarkan userId, diagnosa, dan waktu

  // Fungsi untuk mengelompokkan data berdasarkan userId, diagnosa, dan waktu
  List<Map<String, dynamic>> _groupHistoriData(
    List<Map<String, dynamic>> data,
  ) {
    Map<String, Map<String, dynamic>> groupedMap = {};

    for (var item in data) {
      if (item['userId'] == null || item['tanggal_diagnosa'] == null) continue;

      // Parse tanggal
      DateTime dateTime;
      try {
        dateTime = DateTime.parse(item['tanggal_diagnosa']);
      } catch (e) {
        print("Error parsing date: $e");
        continue;
      }

      // Format tanggal untuk pengelompokan (menit, bukan detik)
      String formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

      // Identifikasi diagnosa
      String diagnosa = '';
      if (item['penyakit_nama'] != null &&
          item['penyakit_nama'].toString().isNotEmpty) {
        diagnosa = 'Penyakit: ${item['penyakit_nama']}';
      } else if (item['hama_nama'] != null &&
          item['hama_nama'].toString().isNotEmpty) {
        diagnosa = 'Hama: ${item['hama_nama']}';
      } else {
        diagnosa = 'Tidak ada diagnosa';
      }

      // Ambil nama user dari kolom 'nama' atau 'name' (sesuaikan dengan struktur data Anda)
     String userName = item['name']?.toString() ?? 'User ID: ${item['userId']}';

      // Buat composite key: userId + waktu + diagnosa
      String key = '${item['userId']}_${formattedTime}_$diagnosa';

      if (!groupedMap.containsKey(key)) {
        // Format tanggal yang lebih ramah untuk tampilan
        String displayDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

        groupedMap[key] = {
          'userId': item['userId'],
          'userName': userName, // Menampilkan nama user, bukan ID
          'diagnosa': diagnosa,
          'tanggal_diagnosa': item['tanggal_diagnosa'],
          'tanggal_display': displayDate,
          'gejala': [],
          'hasil': item['hasil'],
          'penyakit_nama': item['penyakit_nama'],
          'hama_nama': item['hama_nama'],
          'sortTime': dateTime.millisecondsSinceEpoch, // untuk pengurutan
        };
      }

      // Tambahkan gejala jika belum ada dalam list
      if (item['gejala_nama'] != null &&
          !groupedMap[key]!['gejala'].contains(item['gejala_nama'])) {
        groupedMap[key]!['gejala'].add(item['gejala_nama']);
      }
    }

    // Konversi map ke list dan urutkan berdasarkan waktu terbaru
    List<Map<String, dynamic>> result = groupedMap.values.toList();
    result.sort(
      (a, b) => (b['sortTime'] as int).compareTo(a['sortTime'] as int),
    );

    return result;
  }

  // Update pagination
  void _updatePagination(int page) {
    _currentPage = page;
    _totalPages = (groupedHistoriData.length / _rowsPerPage).ceil();

    int startIndex = page * _rowsPerPage;
    int endIndex = (page + 1) * _rowsPerPage;

    if (endIndex > groupedHistoriData.length) {
      endIndex = groupedHistoriData.length;
    }

    if (startIndex >= groupedHistoriData.length) {
      _currentPageData = [];
    } else {
      _currentPageData = groupedHistoriData.sublist(startIndex, endIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Diagnosa'),
        backgroundColor: Color(0xFF9DC08D),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadHistoriData),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text('Error: $error'))
              : groupedHistoriData.isEmpty
              ? Center(child: Text('Tidak ada data riwayat diagnosa'))
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateProperty.all(
                            Color(0xFF9DC08D).withOpacity(0.3),
                          ),
                          columns: [
                            DataColumn(
                              label: Text(
                                'Nama User',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Gejala',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Diagnosa',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Hasil',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Tanggal',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows:
                              _currentPageData.map((histori) {
                                // Gabungkan semua gejala menjadi satu string dengan koma
                                String gejalaText = "Tidak ada gejala";
                                if (histori['gejala'] != null &&
                                    (histori['gejala'] as List).isNotEmpty) {
                                  gejalaText = (histori['gejala'] as List).join(
                                    ', ',
                                  );
                                }

                                return DataRow(
                                  cells: [
                                    DataCell(Text(histori['userName'] ?? 'User tidak ditemukan')),
                                    DataCell(
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Tooltip(
                                          message: gejalaText,
                                          child: Text(
                                            gejalaText,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        histori['diagnosa'] ??
                                            'Tidak ada diagnosa',
                                        style: TextStyle(
                                          color: _getDiagnosaColor(histori),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(_formatHasil(histori['hasil'])),
                                    ),
                                    DataCell(
                                      Text(histori['tanggal_display'] ?? ''),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                  // Pagination controls
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.first_page),
                          onPressed:
                              _currentPage > 0
                                  ? () {
                                    setState(() {
                                      _updatePagination(0);
                                    });
                                  }
                                  : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_left),
                          onPressed:
                              _currentPage > 0
                                  ? () {
                                    setState(() {
                                      _updatePagination(_currentPage - 1);
                                    });
                                  }
                                  : null,
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Halaman ${_currentPage + 1} dari $_totalPages',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(Icons.chevron_right),
                          onPressed:
                              _currentPage < _totalPages - 1
                                  ? () {
                                    setState(() {
                                      _updatePagination(_currentPage + 1);
                                    });
                                  }
                                  : null,
                        ),
                        IconButton(
                          icon: Icon(Icons.last_page),
                          onPressed:
                              _currentPage < _totalPages - 1
                                  ? () {
                                    setState(() {
                                      _updatePagination(_totalPages - 1);
                                    });
                                  }
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  // Rows per page selector
                  Container(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Rows per page: '),
                        DropdownButton<int>(
                          value: _rowsPerPage,
                          items:
                              [10, 20, 50, 100].map((value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value'),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _rowsPerPage = value!;
                              _updatePagination(
                                0,
                              ); // Kembali ke halaman pertama
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Color _getDiagnosaColor(Map<String, dynamic> histori) {
    if (histori['penyakit_nama'] != null) {
      return Colors.red[700]!;
    } else if (histori['hama_nama'] != null) {
      return Colors.amber[800]!;
    }
    return Colors.black;
  }

  String _formatHasil(dynamic hasil) {
    if (hasil == null) return '0%';
    double hasilValue = double.tryParse(hasil.toString()) ?? 0.0;
    return '${(hasilValue * 100).toStringAsFixed(2)}%';
  }
}
