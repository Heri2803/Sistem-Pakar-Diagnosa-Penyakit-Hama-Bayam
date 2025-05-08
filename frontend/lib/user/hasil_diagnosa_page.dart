import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/api_services/api_services.dart';
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
    // Get the first penyakit and hama (if any)
    Map<String, dynamic>? firstPenyakit;
    Map<String, dynamic>? firstHama;

    List<dynamic> penyakitList = widget.hasilDiagnosa['penyakit'] ?? [];
    List<dynamic> hamaList = widget.hasilDiagnosa['hama'] ?? [];

    if (penyakitList.isNotEmpty) {
      firstPenyakit = penyakitList.first;
    }

    if (hamaList.isNotEmpty) {
      firstHama = hamaList.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Diagnosa'),
        backgroundColor: Color(0xFFEDF1D6),
        foregroundColor: Color(0xFF40513B),
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
                      // Main result display
                      _buildDetailedResult(context, firstPenyakit, firstHama),

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
                        penyakitList.length <= 1
                            ? _buildEmptyResult(
                              'Tidak ada kemungkinan penyakit lainnya',
                            )
                            : Column(
                              children:
                                  penyakitList
                                      .skip(
                                        1,
                                      ) // Skip the first one as it's already shown
                                      .map(
                                        (penyakit) => _buildItemCard(
                                          penyakit,
                                          'penyakit',
                                        ),
                                      )
                                      .toList(),
                            ),
                      ),

                      SizedBox(height: 24),

                      // Other possible pests section
                      _buildSection(
                        context,
                        'Kemungkinan Hama Lainnya',
                        hamaList.length <= 1
                            ? _buildEmptyResult(
                              'Tidak ada kemungkinan hama lainnya',
                            )
                            : Column(
                              children:
                                  hamaList
                                      .skip(
                                        1,
                                      ) // Skip the first one as it's already shown
                                      .map(
                                        (hama) => _buildItemCard(hama, 'hama'),
                                      )
                                      .toList(),
                            ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Future<void> _fetchAdditionalData() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('\n=== DEBUG - STARTING DATA FETCH ===');
      print('DEBUG - hasilDiagnosa input: ${widget.hasilDiagnosa}');

      // Fetch all disease and pest data first
      print('DEBUG - Fetching all penyakit and hama data from API...');
      // Fetch all disease and pest data first
      semuaPenyakit = await _apiService.getPenyakit();
      semuaHama = await _apiService.getHama();

      print('\nDEBUG - API Data Summary:');
      print(
        'Fetched ${semuaPenyakit.length} penyakit and ${semuaHama.length} hama from API',
      );

      // Debug log what we got from the API
      print(
        'Fetched ${semuaPenyakit.length} penyakit and ${semuaHama.length} hama from API',
      );

      // Get the lists from the diagnosis result
      List<dynamic> penyakitList = widget.hasilDiagnosa['penyakit'] ?? [];
      List<dynamic> hamaList = widget.hasilDiagnosa['hama'] ?? [];

      // Process diseases
      for (var penyakit in penyakitList) {
        // Make sure the ID exists and convert to string for consistent comparison
        var penyakitId = penyakit['id'];
        if (penyakitId == null) continue;
        print('\nDEBUG - Sample penyakit from API:');

        String penyakitIdStr = penyakitId.toString();

        // Find the matching disease in our complete list
        var detail = semuaPenyakit.firstWhere(
          (item) => item['id'].toString() == penyakitIdStr,
          orElse: () => <String, dynamic>{},
        );

        if (detail.isNotEmpty) {
          // Store the complete details
          penyakitDetails[penyakitIdStr] = {...detail};

          // Debug log
          print(
            'Found details for penyakit ID $penyakitIdStr: ${penyakitDetails[penyakitIdStr]}',
          );
        }
      }

      // Process pests
      for (var hama in hamaList) {
        // Make sure the ID exists and convert to string for consistent comparison
        var hamaId = hama['id'];
        if (hamaId == null) continue;

        String hamaIdStr = hamaId.toString();
        print('\nDEBUG - Sample hama from API:');

        // Find the matching pest in our complete list
        var detail = semuaHama.firstWhere(
          (item) => item['id'].toString() == hamaIdStr,
          orElse: () => <String, dynamic>{},
        );

        if (detail.isNotEmpty) {
          // Store the complete details
          hamaDetails[hamaIdStr] = {...detail};

          // Debug log
          print(
            'Found details for hama ID $hamaIdStr: ${hamaDetails[hamaIdStr]}',
          );
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
    // Create a new map for the result
    Map<String, dynamic> result = {...item};
    // Debug input item
    print('DEBUG - _getCompleteItemData input item: $item');
    print('DEBUG - _getCompleteItemData type: $type');

    // Get the ID and make sure it's a string
    var id = type == 'penyakit' ? item['id_penyakit'] : item['id_hama'];
    print('DEBUG - ID from item: $id (${id?.runtimeType})');
    if (id == null) {
      print('DEBUG - ID is null, returning original item');
      return result;
    }

    String idStr = id.toString();

    // Get the detailed information based on type
    Map<String, dynamic>? details;
    if (type == 'penyakit') {
      print('DEBUG - Looking for penyakit details with ID: $idStr');
      print('DEBUG - Available penyakit keys: ${penyakitDetails.keys}');
      details = penyakitDetails[idStr];
      print('DEBUG - Found penyakit details: $details');

      // Check raw API data if not found
      if (details == null || details.isEmpty) {
        print('DEBUG - Checking raw API data for penyakit ID: $idStr');
        for (var p in semuaPenyakit) {
          print(
            '  Checking penyakit with ID ${p['id']} (${p['id'].runtimeType})',
          );
          if (p['id'].toString() == idStr) {
            print('  MATCH FOUND in raw API data: $p');
            details = p;
            break;
          }
        }
      }
    } else if (type == 'hama') {
      print('DEBUG - Looking for hama details with ID: $idStr');
      print('DEBUG - Available hama keys: ${hamaDetails.keys}');
      details = hamaDetails[idStr];
      print('DEBUG - Found hama details: $details');

      // Check raw API data if not found
      if (details == null || details.isEmpty) {
        print('DEBUG - Checking raw API data for hama ID: $idStr');
        for (var h in semuaHama) {
          print('  Checking hama with ID ${h['id']} (${h['id'].runtimeType})');
          if (h['id'].toString() == idStr) {
            print('  MATCH FOUND in raw API data: $h');
            details = h;
            break;
          }
        }
      }
    }

    // If we have details, merge them with the result
    if (details != null && details.isNotEmpty) {
      print('DEBUG - Merging details into result:');
      print('  Original result before merge: $result');
      print('  Details to merge: $details');
      // Make sure details have priority but preserve the original probabilitas
      double? originalProbabilitas =
          result['probabilitas'] is num
              ? (result['probabilitas'] as num).toDouble()
              : null;

      // Merge the details
      result.addAll(details);

      // Restore original probabilitas if it existed
      if (originalProbabilitas != null) {
        result['probabilitas'] = originalProbabilitas;
      }
      print('DEBUG - Final merged result: $result');

      // Specifically check key fields
      print('DEBUG - Key fields in result:');
      print('  nama: ${result['nama']} (${result['nama']?.runtimeType})');
      print(
        '  deskripsi: ${result['deskripsi']} (${result['deskripsi']?.runtimeType})',
      );
      print(
        '  penanganan: ${result['penanganan']} (${result['penanganan']?.runtimeType})',
      );
      print('  foto: ${result['foto']} (${result['foto']?.runtimeType})');

      // Debug log
      print('Complete data for $type ID $idStr: $result');
    }

    return result;
  }

  Widget _buildDetailedResult(
    BuildContext context,
    Map<String, dynamic>? penyakit,
    Map<String, dynamic>? hama,
  ) {
    // If we have no data, show a message
    if (penyakit == null && hama == null) {
      return _buildEmptyResult('Tidak ada hasil diagnosa yang tersedia');
    }

    // Determine which has higher probability
    bool isPenyakitHigher = false;
    Map<String, dynamic>? highest;
    String type = '';

    // Log the incoming data to debug
    print('DEBUG - Incoming penyakit: $penyakit');
    print('DEBUG - Incoming hama: $hama');

    // Compare probabilities to determine which to show
    if (penyakit != null && hama != null) {
      double pProbabilitas = _getProbabilitas(penyakit);
      double hProbabilitas = _getProbabilitas(hama);

      isPenyakitHigher = pProbabilitas >= hProbabilitas;
      highest = isPenyakitHigher ? penyakit : hama;
      type = isPenyakitHigher ? 'penyakit' : 'hama';
    } else if (penyakit != null) {
      highest = penyakit;
      isPenyakitHigher = true;
      type = 'penyakit';
    } else if (hama != null) {
      highest = hama;
      isPenyakitHigher = false;
      type = 'hama';
    }

    // Safety check
    if (highest == null) {
      return _buildEmptyResult('Tidak ada hasil diagnosa yang tersedia');
    }

    // Get the complete data for the highest item
    final completeData = _getCompleteItemData(highest, type);

    // Debug log
    print('Detail result using: $completeData');

    // Extract the data we need with safe access
    final nama = completeData['nama'] ?? 'Tidak diketahui';
    final deskripsi = completeData['deskripsi'] ?? 'Tidak tersedia';
    final penanganan = completeData['penanganan'] ?? 'Tidak tersedia';
    final foto = completeData['foto'];
    final probabilitas = _getProbabilitas(completeData);

    // Debug log specific fields that should be displayed
    print('DEBUG - nama: $nama (${nama.runtimeType})');
    print('DEBUG - deskripsi: $deskripsi (${deskripsi.runtimeType})');
    print('DEBUG - penanganan: $penanganan (${penanganan.runtimeType})');
    print('DEBUG - foto: $foto (${foto?.runtimeType})');
    print('DEBUG - probabilitas: $probabilitas (${probabilitas.runtimeType})');
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color:
              isPenyakitHigher ? Colors.red.shade300 : Colors.orange.shade300,
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
                  isPenyakitHigher
                      ? Icons.coronavirus_outlined
                      : Icons.bug_report,
                  color:
                      isPenyakitHigher
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
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
                          isPenyakitHigher
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
                    ),
                  ),
                ),
                _buildProbabilityIndicator(probabilitas),
              ],
            ),
            Divider(thickness: 1, height: 24),

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
                          fit: BoxFit.contain, // ✅ agar gambar tidak dipotong
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

            SizedBox(height: 16),

            // Button to see more details
            // Center(
            //   child: TextButton.icon(
            //     icon: Icon(Icons.info_outline),
            //     label: Text('Lihat Detail Lengkap'),
            //     onPressed: () => _showDetailDialog(context, completeData, type),
            //     style: TextButton.styleFrom(
            //       foregroundColor: isPenyakitHigher ? Colors.red.shade700 : Colors.orange.shade700,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, String type) {
    // Get the complete data for this item
    final completeData = _getCompleteItemData(item, type);

    final nama = completeData['nama'] ?? 'Tidak diketahui';
    final probabilitas = _getProbabilitas(completeData);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          type == 'penyakit' ? Icons.coronavirus_outlined : Icons.bug_report,
          color:
              type == 'penyakit' ? Colors.red.shade700 : Colors.orange.shade700,
        ),
        title: Text(nama),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProbabilityIndicator(probabilitas),
            SizedBox(width: 8),
            // IconButton(
            //   icon: Icon(Icons.info_outline),
            //   onPressed: () => _showDetailDialog(context, completeData, type),
            //   color: type == 'penyakit' ? Colors.red.shade700 : Colors.orange.shade700,
            // ),
          ],
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
          '${(value * 100).toStringAsFixed(0)}%',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  double _getProbabilitas(Map<String, dynamic>? item) {
    // If item is null or doesn't contain probabilitas, return 0.0
    if (item == null ||
        !item.containsKey('probabilitas') ||
        item['probabilitas'] == null) {
      return 0.0;
    }

    // Handle different types of probabilitas value
    var probValue = item['probabilitas'];

    if (probValue is double) {
      return probValue;
    } else if (probValue is int) {
      return probValue.toDouble();
    } else if (probValue is String) {
      return double.tryParse(probValue) ?? 0.0;
    } else {
      // For any other type, try to convert to string first then parse
      try {
        return double.tryParse(probValue.toString()) ?? 0.0;
      } catch (e) {
        print('Error parsing probabilitas: $e');
        return 0.0;
      }
    }
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
        '${(value * 100).toStringAsFixed(0)}%',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
