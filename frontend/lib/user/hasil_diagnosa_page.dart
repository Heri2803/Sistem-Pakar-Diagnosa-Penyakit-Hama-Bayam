import 'package:flutter/material.dart';
import 'package:SIBAYAM/user/home_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:SIBAYAM/api_services/api_services.dart';
import 'dart:typed_data';

class HasilDiagnosaPage extends StatefulWidget {
  final Map<String, dynamic> hasilDiagnosa;
  final List<String> gejalaTerpilih;

  HasilDiagnosaPage({
    required this.hasilDiagnosa,
    required this.gejalaTerpilih,
  });

  @override
  _HasilDiagnosaPageState createState() => _HasilDiagnosaPageState();
}

class _HasilDiagnosaPageState extends State<HasilDiagnosaPage> {
  // Maps to store additional data fetched for each item
  Map<String, Map<String, dynamic>> penyakitDetails = {};
  Map<String, Map<String, dynamic>> hamaDetails = {};
  bool isLoading = true;

  // Create an instance of your ApiService
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> semuaPenyakit = [];
  List<Map<String, dynamic>> semuaHama = [];

  @override
  void initState() {
    super.initState();
    _fetchAdditionalData();
  }

  @override
  Widget build(BuildContext context) {
    // Extract data from the nested structure
    final data = widget.hasilDiagnosa['data'] ?? {};
    final List<dynamic> penyakitList = data['penyakit'] ?? [];
    final List<dynamic> hamaList = data['hama'] ?? [];
    final Map<String, dynamic>? hasilTertinggi = data['hasil_tertinggi'];

    // Ambiguity information from backend
    final bool isAmbiguous = data['is_ambiguous'] ?? false;
    final Map<String, dynamic>? ambiguityResolution =
        data['ambiguity_resolution'];

    // Filter information from backend
    final Map<String, dynamic>? filterInfo = data['filter_info'];

    // Get the first penyakit and hama (if any)
    Map<String, dynamic>? firstPenyakit =
        penyakitList.isNotEmpty ? penyakitList.first : null;
    Map<String, dynamic>? firstHama =
        hamaList.isNotEmpty ? hamaList.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Diagnosa'),
        backgroundColor: Color(0xFF9DC08D),
        foregroundColor: Color(0xFF40513B),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF40513B),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
          child: Text(
            'Selesai Diagnosa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFEDF1D6),
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter notification (if applicable)
                      if (filterInfo != null)
                        _buildFilterNotification(filterInfo),

                      // Ambiguity notification (if applicable)
                      if (isAmbiguous && ambiguityResolution != null)
                        _buildAmbiguityNotification(ambiguityResolution),

                      // Main result display - use hasil_tertinggi from backend
                      _buildDetailedResultFromBackend(context, hasilTertinggi),

                      SizedBox(height: 24),

                      // Selected symptoms section
                      _buildSection(
                        context,
                        'Gejala yang Dipilih',
                        widget.gejalaTerpilih.isEmpty
                            ? _buildEmptyResult('Tidak ada gejala yang dipilih')
                            : Card(
                              elevation: 2,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      widget.gejalaTerpilih
                                          .map(
                                            (gejala) => Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 4,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Expanded(child: Text(gejala)),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                      ),

                      SizedBox(height: 24),

                      // Other possible diseases section
                      _buildSection(
                        context,
                        'Kemungkinan Penyakit Lainnya',
                        _buildOtherPossibilities(
                          penyakitList,
                          hasilTertinggi,
                          'penyakit',
                        ),
                      ),

                      SizedBox(height: 24),

                      // Other possible pests section
                      _buildSection(
                        context,
                        'Kemungkinan Hama Lainnya',
                        _buildOtherPossibilities(
                          hamaList,
                          hasilTertinggi,
                          'hama',
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildFilterNotification(Map<String, dynamic> filterInfo) {
    final int totalSebelum = filterInfo['total_sebelum_filter'] ?? 0;
    final int totalSetelah = filterInfo['total_setelah_filter'] ?? 0;
    final int hasilTerfilter = filterInfo['hasil_terfilter'] ?? 0;
    final bool fallbackToSymptomCount =
        filterInfo['fallback_to_symptom_count'] ?? false;
    final String? fallbackReason = filterInfo['fallback_reason'];

    // Only show notification if there's filtering activity
    if (hasilTerfilter == 0 && !fallbackToSymptomCount) {
      return SizedBox.shrink();
    }

    Color cardColor;
    Color iconColor;
    IconData iconData;
    String title;
    String description;

    if (fallbackToSymptomCount) {
      // Fallback scenario
      cardColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade700;
      iconData = Icons.warning_amber_outlined;
      title = 'Penyesuaian Hasil Diagnosa';
      description =
          'Sistem menggunakan kecocokan gejala terbanyak karena hasil dengan akurasi 100% hanya cocok dengan 1 gejala.';
    } else {
      // Normal filtering
      cardColor = Colors.green.shade50;
      iconColor = Colors.green.shade700;
      iconData = Icons.filter_alt_outlined;
      title = 'Filter Hasil Diagnosa';
      description =
          'Sistem memfilter $hasilTerfilter hasil dengan akurasi 100% yang hanya cocok dengan 1 gejala untuk memberikan diagnosis yang lebih akurat.';
    }

    return Card(
      color: cardColor,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: iconColor, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(description, style: TextStyle(fontSize: 14)),
            if (fallbackReason != null) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Alasan: $fallbackReason',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ] else if (!fallbackToSymptomCount) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Total hasil: $totalSebelum → $totalSetelah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmbiguityNotification(Map<String, dynamic> ambiguityResolution) {
    final totalKandidat = ambiguityResolution['total_kandidat'] ?? 0;
    final terpilih = ambiguityResolution['terpilih'] ?? {};
    final alasan = terpilih['alasan'] ?? '';

    return Card(
      color: Colors.blue.shade50,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resolusi Ambiguitas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Ditemukan $totalKandidat kemungkinan dengan nilai probabilitas yang sama. Sistem telah memilih hasil terbaik berdasarkan:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '• $alasan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Metode: Analisis kesesuaian gejala',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedResultFromBackend(
    BuildContext context,
    Map<String, dynamic>? hasilTertinggi,
  ) {
    // If no result from backend, show empty message
    if (hasilTertinggi == null) {
      return _buildEmptyResult('Tidak ada hasil diagnosa yang tersedia');
    }

    // Determine type based on the presence of id fields
    String type = '';
    bool isPenyakit = false;

    if (hasilTertinggi.containsKey('id_penyakit') &&
        hasilTertinggi['id_penyakit'] != null) {
      type = 'penyakit';
      isPenyakit = true;
    } else if (hasilTertinggi.containsKey('id_hama') &&
        hasilTertinggi['id_hama'] != null) {
      type = 'hama';
      isPenyakit = false;
    } else {
      // Fallback: check type field if available
      type = hasilTertinggi['type'] ?? 'unknown';
      isPenyakit = type == 'penyakit';
    }

    // Get the complete data for the result
    final completeData = _getCompleteItemData(hasilTertinggi, type);

    // Extract the data we need with safe access
    final nama =
        completeData['nama'] ?? hasilTertinggi['nama'] ?? 'Tidak diketahui';
    final deskripsi = completeData['deskripsi'] ?? 'Tidak tersedia';
    final penanganan = completeData['penanganan'] ?? 'Tidak tersedia';
    final foto = completeData['foto'];
    final probabilitas = _getProbabilitas(hasilTertinggi);

    // Get additional ambiguity info if available
    final jumlahGejalacocok = hasilTertinggi['jumlah_gejala_cocok'];
    final totalGejalaEntity = hasilTertinggi['total_gejala_entity'];
    final persentaseKesesuaian = hasilTertinggi['persentase_kesesuaian'];

    // Check if this is a perfect match result that would normally be filtered
    final isPerfectSingleMatch =
        (probabilitas * 100).round() == 100 && jumlahGejalacocok == 1;

    // Debug log
    print('DEBUG - Building detailed result for: $nama');
    print('DEBUG - Type: $type, isPenyakit: $isPenyakit');
    print('DEBUG - Probabilitas: $probabilitas');
    print('DEBUG - Is perfect single match: $isPerfectSingleMatch');

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isPenyakit ? Colors.red.shade300 : Colors.orange.shade300,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPenyakit ? Icons.coronavirus_outlined : Icons.bug_report,
                  color:
                      isPenyakit ? Colors.red.shade700 : Colors.orange.shade700,
                  size: 28,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kemungkinan Terbesar: $nama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isPenyakit
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
                    ),
                  ),
                ),
                _buildProbabilityIndicator(probabilitas),
              ],
            ),

            // Show warning if this is a perfect single match result
            if (isPerfectSingleMatch)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Hasil ini dipilih berdasarkan kecocokan gejala terbanyak',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Additional info if ambiguity resolution occurred
            if (jumlahGejalacocok != null && totalGejalaEntity != null)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Kesesuaian: $jumlahGejalacocok/$totalGejalaEntity gejala',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (persentaseKesesuaian != null)
                      Text(
                        ' (${persentaseKesesuaian.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),

            Divider(thickness: 1, height: 24),

            // Image section
            FutureBuilder<Uint8List?>(
              future: ApiService().getPenyakitImageBytesByFilename(
                foto.toString(),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  return Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: 180,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Gambar tidak tersedia',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 16),

            // Description
            Text(
              'Deskripsi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(deskripsi, style: TextStyle(fontSize: 14)),
            SizedBox(height: 16),

            // Treatment
            Text(
              'Penanganan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(penanganan, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

 Widget _buildOtherPossibilities(
    List<dynamic> itemList,
    Map<String, dynamic>? hasilTertinggi,
    String type,
) {
  // Check if there's a 100% match in hasilTertinggi
  if (hasilTertinggi != null) {
    double probabilitas = _getProbabilitas(hasilTertinggi);
    if ((probabilitas * 100).round() == 100) {
      return _buildEmptyResult(
        'Ditemukan kecocokan 100% pada diagnosa utama',
      );
    }
  }

  if (itemList.isEmpty) {
    return _buildEmptyResult('Tidak ada kemungkinan ${type} lainnya');
  }

  // Get the probability of the main diagnosis result
  double? mainDiagnosisProbability;
  if (hasilTertinggi != null) {
    mainDiagnosisProbability = _getProbabilitas(hasilTertinggi);
  }

  // Filter out items with 100% probability and the top result
  List otherItems = [];

  if (hasilTertinggi != null) {
    // Get the ID of the top result
    String? topResultId;
    if (type == 'penyakit' && hasilTertinggi.containsKey('id_penyakit')) {
      topResultId = hasilTertinggi['id_penyakit']?.toString();
    } else if (type == 'hama' && hasilTertinggi.containsKey('id_hama')) {
      topResultId = hasilTertinggi['id_hama']?.toString();
    }

    // Filter out the top result AND items with 100% probability AND items with higher probability than main diagnosis
    otherItems = itemList.where((item) {
      String? itemId;
      if (type == 'penyakit') {
        itemId = item['id_penyakit']?.toString();
      } else {
        itemId = item['id_hama']?.toString();
      }
      
      // Skip if this is the top result
      if (topResultId != null && itemId == topResultId) {
        return false;
      }
      
      // Get item probability
      double itemProbabilitas = _getProbabilitas(item);
      
      // Skip if this item has 100% probability
      if ((itemProbabilitas * 100).round() == 100) {
        return false;
      }
      
      // Skip if this item has higher probability than main diagnosis
      if (mainDiagnosisProbability != null && itemProbabilitas > mainDiagnosisProbability) {
        return false;
      }
      
      return true;
    }).toList();
  } else {
    // If no hasilTertinggi, filter out 100% probability items from all except first
    otherItems = itemList.skip(1).where((item) {
      double itemProbabilitas = _getProbabilitas(item);
      return (itemProbabilitas * 100).round() != 100;
    }).toList();
  }

  if (otherItems.isEmpty) {
    return _buildEmptyResult('Tidak ada kemungkinan ${type} lainnya');
  }

  return Column(
    children: otherItems.map((item) => _buildItemCard(item, type)).toList(),
  );
}

  Future<void> _fetchAdditionalData() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('\n=== DEBUG - STARTING DATA FETCH ===');
      print('DEBUG - hasilDiagnosa input: ${widget.hasilDiagnosa}');

      // Fetch all disease and pest data
      print('DEBUG - Fetching all penyakit and hama data from API...');
      semuaPenyakit = await _apiService.getPenyakit();
      semuaHama = await _apiService.getHama();

      print('\nDEBUG - API Data Summary:');
      print(
        'Fetched ${semuaPenyakit.length} penyakit and ${semuaHama.length} hama from API',
      );

      // Get the data from the new backend structure
      final data = widget.hasilDiagnosa['data'] ?? {};
      final List<dynamic> penyakitList = data['penyakit'] ?? [];
      final List<dynamic> hamaList = data['hama'] ?? [];

      // Process diseases
      for (var penyakit in penyakitList) {
        var penyakitId = penyakit['id_penyakit'];
        if (penyakitId == null) continue;

        String penyakitIdStr = penyakitId.toString();
        print('DEBUG - Processing penyakit ID: $penyakitIdStr');

        var detail = semuaPenyakit.firstWhere(
          (item) => item['id'].toString() == penyakitIdStr,
          orElse: () => <String, dynamic>{},
        );

        if (detail.isNotEmpty) {
          double probability = 0.0;
          if (penyakit.containsKey('probabilitas_persen')) {
            probability =
                (penyakit['probabilitas_persen'] as num).toDouble() / 100;
          } else if (penyakit.containsKey('nilai_bayes')) {
            probability = (penyakit['nilai_bayes'] as num).toDouble();
          }

          penyakitDetails[penyakitIdStr] = {
            ...detail,
            'probabilitas': probability,
            'id_penyakit': penyakitIdStr,
          };

          final nama =
              penyakitDetails[penyakitIdStr]?['nama'] ?? 'Nama tidak ditemukan';
          print('DEBUG - Found details for penyakit ID $penyakitIdStr: $nama');
        }
      }

      // Process pests
      for (var hama in hamaList) {
        var hamaId = hama['id_hama'];
        if (hamaId == null) continue;

        String hamaIdStr = hamaId.toString();
        print('DEBUG - Processing hama ID: $hamaIdStr');

        var detail = semuaHama.firstWhere(
          (item) => item['id'].toString() == hamaIdStr,
          orElse: () => <String, dynamic>{},
        );

        if (detail.isNotEmpty) {
          double probability = 0.0;
          if (hama.containsKey('probabilitas_persen')) {
            probability = (hama['probabilitas_persen'] as num).toDouble() / 100;
          } else if (hama.containsKey('nilai_bayes')) {
            probability = (hama['nilai_bayes'] as num).toDouble();
          }

          hamaDetails[hamaIdStr] = {
            ...detail,
            'probabilitas': probability,
            'id_hama': hamaIdStr,
          };

          final nama =
              hamaDetails[hamaIdStr]?['nama'] ?? 'Nama tidak ditemukan';
          print('DEBUG - Found details for hama ID $hamaIdStr: $nama');
        }
      }
    } catch (e) {
      print('Error fetching additional data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getCompleteItemData(
    Map<String, dynamic> item,
    String type,
  ) {
    Map<String, dynamic> result = {...item};

    var id = type == 'penyakit' ? item['id_penyakit'] : item['id_hama'];

    print('DEBUG - _getCompleteItemData type: $type, id: $id');
    if (id == null) {
      print('DEBUG - ID is null, returning original item');
      return result;
    }

    String idStr = id.toString();

    Map<String, dynamic>? details;
    if (type == 'penyakit') {
      details = penyakitDetails[idStr];

      if (details == null || details.isEmpty) {
        print(
          'DEBUG - No cached details for penyakit ID: $idStr, searching API data...',
        );
        details = semuaPenyakit.firstWhere(
          (p) => p['id'].toString() == idStr,
          orElse: () => <String, dynamic>{},
        );

        if (details.isNotEmpty) {
          penyakitDetails[idStr] = {...details};
        }
      }
    } else if (type == 'hama') {
      details = hamaDetails[idStr];

      if (details == null || details.isEmpty) {
        print(
          'DEBUG - No cached details for hama ID: $idStr, searching API data...',
        );
        details = semuaHama.firstWhere(
          (h) => h['id'].toString() == idStr,
          orElse: () => <String, dynamic>{},
        );

        if (details.isNotEmpty) {
          hamaDetails[idStr] = {...details};
        }
      }
    }

    if (details != null && details.isNotEmpty) {
      print('DEBUG - Found details for $type ID $idStr: ${details['nama']}');

      double probability = 0.0;

      if (item.containsKey('probabilitas_persen')) {
        probability = (item['probabilitas_persen'] as num).toDouble() / 100;
      } else if (item.containsKey('nilai_bayes')) {
        probability = (item['nilai_bayes'] as num).toDouble();
      } else if (item.containsKey('probabilitas')) {
        probability = _getProbabilitas(item);
      }

      result = {
        ...details,
        ...result,
        'probabilitas': probability,
        'id': idStr,
        type == 'penyakit' ? 'id_penyakit' : 'id_hama': idStr,
      };

      print(
        'DEBUG - Final data for $type ID $idStr (${result['nama']}): probabilitas=${result['probabilitas']}',
      );
    } else {
      print('DEBUG - No details found for $type ID $idStr');
    }

    return result;
  }

  Widget _buildItemCard(Map<String, dynamic> item, String type) {
    final completeData = _getCompleteItemData(item, type);
    final nama = completeData['nama'] ?? 'Tidak diketahui';
    final probabilitas = _getProbabilitas(completeData);

    // Get additional info for display
    final jumlahGejalacocok = item['jumlah_gejala_cocok'];
    final totalGejalaEntity = item['total_gejala_entity'];
    final persentaseKesesuaian = item['persentase_kesesuaian'];

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          type == 'penyakit' ? Icons.coronavirus_outlined : Icons.bug_report,
          color: type == 'penyakit' ? Color(0xFF9DC08D) : Color(0xFF7A9A6D),
          size: 24,
        ),
        title: Text(
          nama,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF40513B),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (jumlahGejalacocok != null && totalGejalaEntity != null) ...[
              SizedBox(height: 4),
              Text(
                'Kesesuaian: $jumlahGejalacocok/$totalGejalaEntity gejala',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (persentaseKesesuaian != null)
                Text(
                  '(${persentaseKesesuaian.toStringAsFixed(1)}%)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ],
        ),
        trailing: Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: type == 'penyakit' ? Color(0xFF9DC08D) : Color(0xFF7A9A6D),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              '${(probabilitas * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF40513B),
            ),
          ),
        ),
        SizedBox(height: 10),
        content,
      ],
    );
  }

  Widget _buildEmptyResult(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildProbabilityIndicator(double value) {
    final Color indicatorColor =
        value > 0.7
            ? Colors.red
            : value > 0.4
            ? Colors.orange
            : Colors.green;

    return Container(
      width: 60,
      height: 30,
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          '${((value * 1000).floor()/10).toStringAsFixed(1)}%',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  double _getProbabilitas(Map<String, dynamic>? item) {
    if (item == null) {
      return 0.0;
    }

    if (item.containsKey('probabilitas_persen')) {
      var value = item['probabilitas_persen'];
      if (value is num) {
        return value.toDouble() / 100;
      } else if (value is String) {
        return (double.tryParse(value) ?? 0.0) / 100;
      }
    }

    if (item.containsKey('nilai_bayes')) {
      var value = item['nilai_bayes'];
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
    }

    if (item.containsKey('probabilitas')) {
      var value = item['probabilitas'];
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
    }
    return 0.0;
  }
}

Widget _buildEmptyResult(String message) {
  return Card(
    elevation: 2,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      ),
    ),
  );
}

Widget _buildProbabilityIndicator(double value) {
  Color color;
  if (value >= 0.7) {
    color = Colors.red;
  } else if (value >= 0.4) {
    color = Colors.orange;
  } else {
    color = Colors.green;
  }

  return Container(
    width: 60,
    height: 30,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Center(
      child: Text(
        '${((value * 1000).floor()/10).toStringAsFixed(1)}%',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
