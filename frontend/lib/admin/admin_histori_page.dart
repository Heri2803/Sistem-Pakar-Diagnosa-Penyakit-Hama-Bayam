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
  bool isLoading = true;
  String? error;

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
          final userHistori = await apiService.fetchHistoriDenganDetail(histori['userId'].toString());
          detailedHistori.addAll(userHistori);
        }
      }

      setState(() {
        historiData = detailedHistori;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Diagnosa'),
        backgroundColor: Color(0xFF9DC08D),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadHistoriData,
          ),
        ],
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : error != null
          ? Center(child: Text('Error: $error'))
          : historiData.isEmpty
            ? Center(child: Text('Tidak ada data riwayat diagnosa'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: MaterialStateProperty.all(
                      Color(0xFF9DC08D).withOpacity(0.3),
                    ),
                    columns: [
                      DataColumn(label: Text('Nama User', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Gejala', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Diagnosa', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Hasil', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: historiData.map((histori) {
                      return DataRow(
                        cells: [
                          DataCell(Text(histori['name'] ?? 'Unknown')), // Changed 'name' to 'user_name'
                          DataCell(
                            Container(
                              constraints: BoxConstraints(maxWidth: 200),
                              child: Tooltip(
                                message: histori['gejala_nama'] ?? 'Tidak ada gejala',
                                child: Text(
                                  histori['gejala_nama'] ?? 'Tidak ada gejala',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _getDiagnosaText(histori),
                              // Removed style with color formatting
                            )
                          ),
                          DataCell(Text(_formatHasil(histori['hasil']))),
                          DataCell(Text(_formatDate(histori['tanggal_diagnosa']))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
    );
  }

  String _getDiagnosaText(Map<String, dynamic> histori) {
    if (histori['penyakit_nama'] != null) {
      return 'Penyakit: ${histori['penyakit_nama']}';
    } else if (histori['hama_nama'] != null) {
      return 'Hama: ${histori['hama_nama']}';
    }
    return 'Tidak ada diagnosa';
  }

  // Removed _getDiagnosaColor method as it's no longer needed

  String _formatHasil(dynamic hasil) {
    if (hasil == null) return '0%';
    double hasilValue = double.tryParse(hasil.toString()) ?? 0.0;
    return '${(hasilValue * 100).toStringAsFixed(2)}%';
  }

  String _formatDate(dynamic tanggal) {
    if (tanggal == null) return '';
    try {
      DateTime date = DateTime.parse(tanggal.toString());
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return '';
    }
  }
}