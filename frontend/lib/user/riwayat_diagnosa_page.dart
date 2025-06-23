import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
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
  List<Map<String, dynamic>> _filteredRiwayatData = [];
  final ApiService apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _userId;
  String? _token;
  String? _email;
  
  // Filter variables
  int? _selectedYear;
  int? _selectedMonth;
  List<int> _availableYears = [];
  List<int> _availableMonths = [];

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
      var url = Uri.parse(
        "http://202.74.74.214:5000/api/users",
      );

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
          'dateTime': dateTime, // Tambahkan DateTime object untuk filtering
          'composite_key': compositeKey, // Tambahkan composite key untuk delete
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
        _riwayatData = groupedData;
        _filteredRiwayatData = List.from(groupedData);
        _isLoading = false;
      });

      // Extract available years and months for filter
      _extractAvailableYearsAndMonths();

      print("Successfully fetched ${_riwayatData.length} history records");
    } catch (e) {
      print("Error fetching histori data: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Gagal memuat data riwayat: ${e.toString()}";
      });
    }
  }

  void _extractAvailableYearsAndMonths() {
    Set<int> years = {};
    Set<int> months = {};

    for (var riwayat in _riwayatData) {
      if (riwayat['dateTime'] != null) {
        DateTime dateTime = riwayat['dateTime'];
        years.add(dateTime.year);
        months.add(dateTime.month);
      }
    }

    setState(() {
      _availableYears = years.toList()..sort((a, b) => b.compareTo(a));
      _availableMonths = months.toList()..sort();
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredRiwayatData = _riwayatData.where((riwayat) {
        if (riwayat['dateTime'] == null) return false;
        
        DateTime dateTime = riwayat['dateTime'];
        
        bool yearMatch = _selectedYear == null || dateTime.year == _selectedYear;
        bool monthMatch = _selectedMonth == null || dateTime.month == _selectedMonth;
        
        return yearMatch && monthMatch;
      }).toList();
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedYear = null;
      _selectedMonth = null;
      _filteredRiwayatData = List.from(_riwayatData);
    });
  }

  Future<void> _deleteRiwayat(String compositeKey) async {
  try {
    // Cari data riwayat berdasarkan composite key
    Map<String, dynamic>? riwayatToDelete;
    for (var riwayat in _riwayatData) {
      if (riwayat['composite_key'] == compositeKey) {
        riwayatToDelete = riwayat;
        break;
      }
    }

    if (riwayatToDelete == null) {
      throw Exception('Data riwayat tidak ditemukan');
    }

    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apakah Anda yakin ingin menghapus riwayat diagnosa ini?'),
              SizedBox(height: 8),
              Text(
                'Diagnosis: ${riwayatToDelete!['diagnosis']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Tanggal: ${riwayatToDelete['tanggal_diagnosa']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Menghapus data..."),
                ],
              ),
            ),
          );
        },
      );

      // Panggil API untuk menghapus data berdasarkan userId dan tanggal
      final result = await apiService.deleteHistoriByUserAndDate(
        userId: _userId!,
        tanggalDiagnosa: riwayatToDelete['tanggal_diagnosa_raw'],
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (result['success']) {
        // Remove from local data jika API berhasil
        setState(() {
          _riwayatData.removeWhere((item) => item['composite_key'] == compositeKey);
          _filteredRiwayatData.removeWhere((item) => item['composite_key'] == compositeKey);
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Riwayat berhasil dihapus'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menghapus riwayat'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  } catch (e) {
    // Close loading dialog if still open
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    
    print("Error deleting riwayat: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal menghapus riwayat: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

  Widget _buildFilterSection() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Riwayat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: _selectedYear,
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Semua Tahun'),
                      ),
                      ..._availableYears.map((year) => DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                      });
                      _applyFilter();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: _selectedMonth,
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Semua Bulan'),
                      ),
                      ...List.generate(12, (index) => index + 1).map((month) {
                        List<String> monthNames = [
                          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                        ];
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(monthNames[month - 1]),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                      });
                      _applyFilter();
                    },
                  ),
                ),
              ],
            ),
            if (_selectedYear != null || _selectedMonth != null) ...[
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearFilter,
                  icon: Icon(Icons.clear, size: 16),
                  label: Text('Hapus Filter'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
            _selectedYear != null || _selectedMonth != null
                ? 'Tidak ada riwayat diagnosa untuk filter yang dipilih.'
                : 'Belum ada riwayat diagnosa.',
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _errorMessage != null
                ? _buildErrorWidget()
                : Column(
                    children: [
                      _buildFilterSection(),
                      Expanded(
                        child: _filteredRiwayatData.isEmpty
                            ? _buildEmptyHistoryWidget()
                            : ListView.builder(
                                itemCount: _filteredRiwayatData.length,
                                itemBuilder: (context, index) {
                                  final riwayat = _filteredRiwayatData[index];

                                  // Safely handle potential null values
                                  List<dynamic> gejalaList = [];
                                  if (riwayat.containsKey('gejala') &&
                                      riwayat['gejala'] != null) {
                                    gejalaList = riwayat['gejala'] as List<dynamic>;
                                  }

                                  final gejalaText = gejalaList.isEmpty
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
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 18,
                                                    color: Colors.grey[700],
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    '${riwayat['tanggal_diagnosa'] ?? "Tanggal tidak tersedia"}',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
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
                                                  SizedBox(width: 8),
                                                  // Delete button
                                                  InkWell(
                                                    onTap: () => _deleteRiwayat(
                                                        riwayat['composite_key']),
                                                    child: Container(
                                                      padding: EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red[100],
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Icon(
                                                        Icons.delete_outline,
                                                        size: 18,
                                                        color: Colors.red[600],
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                                                'Hasil: ${riwayat['hasil'] != null ? "${(((riwayat['hasil'] as num) * 1000).floor() / 10).toStringAsFixed(1)}%" : "-"}',
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
                                                        builder: (context) =>
                                                            DetailRiwayatPage(
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
                    ],
                  ),
      ),
    );
  }
}