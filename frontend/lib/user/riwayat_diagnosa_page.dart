import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';
import 'detail_riwayat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class RiwayatDiagnosaPage extends StatefulWidget {
  final String? userId;

  RiwayatDiagnosaPage({this.userId});

  @override
  _RiwayatDiagnosaPageState createState() => _RiwayatDiagnosaPageState();
}

class _RiwayatDiagnosaPageState extends State<RiwayatDiagnosaPage> {
  List<Map<String, dynamic>> _riwayatData = [];
  final ApiService apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _userId;
  String? _token;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchHistori();
  }

  Future<void> _loadUserDataAndFetchHistori() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Ambil data user yang sedang login dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _email = prefs.getString('email');

      // Check if already has userId from widget constructor
      _userId = widget.userId;

      print("Token from SharedPreferences: $_token");
      print("Email from SharedPreferences: $_email");
      print("Initial userId: $_userId");

      // If no token or email, we can't proceed
      if (_token == null || _email == null) {
        throw Exception('Sesi login tidak ditemukan, silahkan login kembali');
      }

      // If we don't have userId yet, we need to fetch user data first
      if (_userId == null || _userId!.isEmpty) {
        await _fetchUserData();
      }

      // Double-check if userId is still null after fetching
      if (_userId == null || _userId!.isEmpty) {
        throw Exception('Gagal mendapatkan ID pengguna');
      }

      // Now that we have userId, fetch the history data
      await _fetchHistoriData();
    } catch (e) {
      print("Error in _loadUserDataAndFetchHistori: $e");

      // Check if the error is about authentication
      if (e.toString().contains('login') || e.toString().contains('sesi')) {
        // Clear any existing user data and redirect to login
        await ApiService.logoutUser();

        // Navigate to login page in the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Fetch user data to get user ID
  Future<void> _fetchUserData() async {
    try {
      // Buat URL untuk endpoint user API
      var url = Uri.parse("http://localhost:5000/api/users");

      // Kirim permintaan GET dengan token autentikasi
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      if (response.statusCode == 200) {
        // Parse data respons
        List<dynamic> users = jsonDecode(response.body);
        print("Email login: $_email");
        print("Users data from server: ${users.length} users");

        // Cari user dengan email yang sama dengan yang login
        Map<String, dynamic>? currentUser;
        for (var user in users) {
          if (user['email'].toString().toLowerCase() == _email!.toLowerCase()) {
            currentUser = Map<String, dynamic>.from(user);
            print(
              "User found: ${currentUser['name']} with ID: ${currentUser['id']}",
            );
            break;
          }
        }

        if (currentUser == null) {
          throw Exception('Data pengguna tidak ditemukan');
        }

        // Save userId to SharedPreferences for future use
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', currentUser['id'].toString());

        // Update state with user ID
        setState(() {
          _userId = currentUser!['id'].toString();
        });

        print("User ID set to: $_userId");
      } else if (response.statusCode == 401) {
        // Token tidak valid atau expired
        await ApiService.logoutUser();
        throw Exception('Sesi habis, silahkan login kembali');
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching user data: $e");
      throw e; // Re-throw for the caller to handle
    }
  }

  // Fungsi baru untuk mengelompokkan berdasarkan diagnosis dan waktu yang sama
  List<Map<String, dynamic>> _groupHistoriByDiagnosis(
    List<Map<String, dynamic>> data,
  ) {
    final Map<String, Map<String, dynamic>> groupedData = {};
    print("Data mentah dari API (setelah filter userId): $data");

    for (var item in data) {
      final String? penyakitNama = item['penyakit_nama'];
      final String? hamaNama = item['hama_nama'];
      final String? tanggalDiagnosa = item['tanggal_diagnosa'];

      final int? idPenyakit = item['id_penyakit'];
      final int? idHama = item['id_hama'];

      final hasPenyakit =
          penyakitNama != null && penyakitNama.toString().isNotEmpty;
      final hasHama = hamaNama != null && hamaNama.toString().isNotEmpty;

      if (!hasPenyakit && !hasHama) {
        print("Item dilewati karena tidak memiliki penyakit atau hama: $item");
        continue;
      }

      if (tanggalDiagnosa == null) {
        print("Item dilewati karena tidak memiliki tanggal diagnosa: $item");
        continue;
      }

      // Gabungkan nama penyakit dan hama jika keduanya ada
      String diagnosisKey = '';
      if (hasPenyakit && hasHama) {
        diagnosisKey = '$penyakitNama & $hamaNama';
      } else if (hasPenyakit) {
        diagnosisKey = penyakitNama!;
      } else {
        diagnosisKey = hamaNama!;
      }

      // Tentukan diagnosis_type
      String diagnosisType =
          hasPenyakit && hasHama
              ? 'penyakit & hama'
              : hasPenyakit
              ? 'penyakit'
              : 'hama';

      // Format tanggal waktu ke format Indonesia
      String formattedDateTime = '';
      String rawDateTime = '';
      DateTime dateTime;

      try {
        // Parsing tanggal dari string yang datang dari API
        dateTime = DateTime.parse(tanggalDiagnosa);

        // Buat format tanggal dan waktu yang lebih ramah pengguna
        String day = dateTime.day.toString().padLeft(2, '0');
        String month = dateTime.month.toString().padLeft(2, '0');
        String year = dateTime.year.toString();
        String hour = dateTime.hour.toString().padLeft(2, '0');
        String minute = dateTime.minute.toString().padLeft(2, '0');
        String second = dateTime.second.toString().padLeft(2, '0');

        formattedDateTime = '$day-$month-$year $hour:$minute:$second WIB';

        // Format timestamp untuk pengelompokan (tanpa detik untuk mengelompokkan waktu yang "sama")
        rawDateTime = '$year-$month-$day $hour:$minute';
      } catch (e) {
        print("Error parsing date: $e for date: $tanggalDiagnosa");
        formattedDateTime = 'Tanggal tidak valid';
        rawDateTime = 'invalid';
        continue; // Skip item with invalid date
      }

      // Buat composite key untuk pengelompokan (gabungan diagnosa dan waktu)
      final compositeKey = '$diagnosisKey##$rawDateTime';

      // Inisialisasi grup jika belum ada
      if (!groupedData.containsKey(compositeKey)) {
        groupedData[compositeKey] = {
          'diagnosis': diagnosisKey,
          'diagnosis_type': diagnosisType,
          'gejala': <String>[],
          'hasil': item['hasil'],
          'tanggal_diagnosa': formattedDateTime,
          'tanggal_diagnosa_raw': tanggalDiagnosa,
          'id_penyakit': idPenyakit,
          'id_hama': idHama,
          'timestamp': rawDateTime, // menyimpan waktu untuk sorting
        };
      }

      // Tambahkan gejala jika belum ada
      if (item['gejala_nama'] != null) {
        final gejalaNama = item['gejala_nama'];
        if (!groupedData[compositeKey]!['gejala'].contains(gejalaNama)) {
          groupedData[compositeKey]!['gejala'].add(gejalaNama);
        }
      }
    }

    // Konversi ke list dan urutkan berdasarkan timestamp terbaru
    final result = groupedData.values.toList();
    result.sort((a, b) {
      final String timestampA = a['timestamp'] ?? '';
      final String timestampB = b['timestamp'] ?? '';
      return timestampB.compareTo(timestampA); // descending (terbaru dulu)
    });

    print(
      "Hasil pengelompokan berdasarkan diagnosa dan waktu: ${result.length} entries",
    );
    return result;
  }

  Future<void> _fetchHistoriData() async {
    try {
      print("Fetching histori dengan userId: $_userId");

      // Panggil API untuk mendapatkan data histori
      final historiResponse = await apiService.fetchHistoriDenganDetail(
        _userId!,
      );

      // Kelompokkan data berdasarkan diagnosis
      final groupedData = _groupHistoriByDiagnosis(historiResponse);

      setState(() {
        _riwayatData =
            groupedData; // Use groupedData instead of historiResponse
        _isLoading = false;
      });

      print("Successfully fetched ${_riwayatData.length} history records");
    } catch (e) {
      print("Error fetching histori data: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Gagal memuat data riwayat: ${e.toString()}";
      });
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadUserDataAndFetchHistori,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF9DC08D),
            ),
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            'Belum ada riwayat diagnosa.',
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D),
      appBar: AppBar(
        backgroundColor: Color(0xFF9DC08D),
        title: Text(
          "Riwayat Diagnosa",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : _errorMessage != null
                ? _buildErrorWidget()
                : _riwayatData.isEmpty
                ? _buildEmptyHistoryWidget()
                : ListView.builder(
                  itemCount: _riwayatData.length,
                  itemBuilder: (context, index) {
                    final riwayat = _riwayatData[index];

                    // Safely handle potential null values
                    List<dynamic> gejalaList = [];
                    if (riwayat.containsKey('gejala') &&
                        riwayat['gejala'] != null) {
                      gejalaList = riwayat['gejala'] as List<dynamic>;
                    }

                    final gejalaText =
                        gejalaList.isEmpty
                            ? "Tidak ada gejala tercatat"
                            : gejalaList.join(', ');

                    // Mendapatkan jenis diagnosis (penyakit/hama/keduanya)
                    final String diagnosisType =
                        riwayat['diagnosis_type'] ?? 'Tidak diketahui';

                    // Mendapatkan badge warna berdasarkan jenis diagnosis
                    Color badgeColor;
                    switch (diagnosisType) {
                      case 'penyakit':
                        badgeColor = Color(0xFF9DC08D); // Warna untuk penyakit
                        break;
                      case 'hama':
                        badgeColor = Color(
                          0xFF7A9A6D,
                        ); // Warna lebih gelap untuk hama
                        break;
                      case 'penyakit & hama':
                        badgeColor = Color(
                          0xFF5C7452,
                        ); // Warna paling gelap untuk kombinasi
                        break;
                      default:
                        badgeColor = Colors.grey[300]!;
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Column(
                        children: [
                          // Header dengan waktu diagnosa
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFE1EDD5),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${riwayat['tanggal_diagnosa'] ?? "Tanggal tidak tersedia"}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                // Badge jenis diagnosis
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    diagnosisType,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diagnosis: ${riwayat['diagnosis']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Gejala: $gejalaText',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Hasil: ${(riwayat['hasil'] as num?)?.toStringAsFixed(2) ?? "-"}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      print(
                                        "Navigating to DetailRiwayatPage with data: $riwayat",
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetailRiwayatPage(
                                                detailRiwayat:
                                                    riwayat, // Kirim data riwayat ke halaman detail
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF9DC08D),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Lihat Detail'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
