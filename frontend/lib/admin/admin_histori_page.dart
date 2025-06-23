import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
import 'package:intl/intl.dart';

class AdminHistoriPage extends StatefulWidget {
  @override
  _AdminHistoriPageState createState() => _AdminHistoriPageState();
}

class _AdminHistoriPageState extends State<AdminHistoriPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> historiData = [];
  List<Map<String, dynamic>> groupedHistoriData = [];
  List<Map<String, dynamic>> filteredHistoriData = []; // Data yang sudah difilter
  bool isLoading = true;
  String? error;

  // Search variables
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Date filter variables
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  String? selectedMonth;
  String? selectedYear;
  
  // Month and year options
  final List<String> months = [
    'Semua Bulan',
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  
  List<String> years = ['Semua Tahun'];

  // Pagination variables
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int _totalPages = 0;
  List<Map<String, dynamic>> _currentPageData = [];

  @override
  void initState() {
    super.initState();
    _initializeYears();
    selectedMonth = 'Semua Bulan';
    selectedYear = 'Semua Tahun';
    _loadHistoriData();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _initializeYears() {
    int currentYear = DateTime.now().year;
    for (int i = currentYear; i >= currentYear - 10; i--) {
      years.add(i.toString());
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
      _filterData();
      _updatePagination(0); // Reset ke halaman pertama saat search
    });
  }

  void _onDateFilterChanged() {
    setState(() {
      _filterData();
      _updatePagination(0); // Reset ke halaman pertama saat filter
    });
  }

  void _filterData() {
    List<Map<String, dynamic>> tempData = List.from(groupedHistoriData);

    // Filter berdasarkan search query
    if (searchQuery.isNotEmpty) {
      tempData = tempData.where((histori) {
        final userName = (histori['userName'] ?? '').toString().toLowerCase();
        final diagnosa = (histori['diagnosa'] ?? '').toString().toLowerCase();
        
        return userName.contains(searchQuery) || diagnosa.contains(searchQuery);
      }).toList();
    }

    // Filter berdasarkan range tanggal
    if (selectedFromDate != null && selectedToDate != null) {
      tempData = tempData.where((histori) {
        if (histori['tanggal_diagnosa'] == null) return false;
        
        try {
          DateTime itemDate = DateTime.parse(histori['tanggal_diagnosa']);
          DateTime fromDate = DateTime(selectedFromDate!.year, selectedFromDate!.month, selectedFromDate!.day);
          DateTime toDate = DateTime(selectedToDate!.year, selectedToDate!.month, selectedToDate!.day, 23, 59, 59);
          
          return itemDate.isAfter(fromDate.subtract(Duration(seconds: 1))) && 
                 itemDate.isBefore(toDate.add(Duration(seconds: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Filter berdasarkan bulan dan tahun
    if (selectedMonth != 'Semua Bulan' || selectedYear != 'Semua Tahun') {
      tempData = tempData.where((histori) {
        if (histori['tanggal_diagnosa'] == null) return false;
        
        try {
          DateTime itemDate = DateTime.parse(histori['tanggal_diagnosa']);
          
          bool monthMatch = selectedMonth == 'Semua Bulan' || 
                           itemDate.month == months.indexOf(selectedMonth!);
          
          bool yearMatch = selectedYear == 'Semua Tahun' || 
                          itemDate.year.toString() == selectedYear;
          
          return monthMatch && yearMatch;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    filteredHistoriData = tempData;
  }

  Future<void> _loadHistoriData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Dapatkan semua histori terlebih dahulu
      final allHistori = await apiService.getAllHistori();
      
      // Kumpulkan semua userIds yang unik
      Set<String> uniqueUserIds = allHistori
          .where((histori) => histori['userId'] != null)
          .map((histori) => histori['userId'].toString())
          .toSet();

      // Jalankan semua fetchHistoriDenganDetail secara paralel
      List<Future<List<Map<String, dynamic>>>> futures = uniqueUserIds
          .map((userId) => apiService.fetchHistoriDenganDetail(userId))
          .toList();

      // Tunggu semua futures selesai
      List<List<Map<String, dynamic>>> results = await Future.wait(futures);
      
      // Gabungkan semua hasil
      List<Map<String, dynamic>> detailedHistori = [];
      for (var result in results) {
        detailedHistori.addAll(result);
      }

      // Kelompokkan data berdasarkan user, diagnosa, dan waktu yang sama
      final groupedData = _groupHistoriData(detailedHistori);

      setState(() {
        historiData = detailedHistori; // Simpan data asli jika perlu
        groupedHistoriData = groupedData; // Data yang sudah dikelompokkan
        filteredHistoriData = List.from(groupedData); // Initialize filtered data
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

      // Ambil nama user dari kolom 'nama' atau 'name'
      String userName = item['name']?.toString() ?? 'User ID: ${item['userId']}';

      // Buat composite key: userId + waktu + diagnosa
      String key = '${item['userId']}_${formattedTime}_$diagnosa';

      if (!groupedMap.containsKey(key)) {
        // Format tanggal yang lebih ramah untuk tampilan
        String displayDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

        groupedMap[key] = {
          'userId': item['userId'],
          'userName': userName,
          'diagnosa': diagnosa,
          'tanggal_diagnosa': item['tanggal_diagnosa'],
          'tanggal_display': displayDate,
          'gejala': [],
          'hasil': item['hasil'],
          'penyakit_nama': item['penyakit_nama'],
          'hama_nama': item['hama_nama'],
          'sortTime': dateTime.millisecondsSinceEpoch,
          'detailData': [], // Menyimpan semua item detail untuk halaman detail
        };
      }

      // Tambahkan gejala jika belum ada dalam list
      if (item['gejala_nama'] != null &&
          !groupedMap[key]!['gejala'].contains(item['gejala_nama'])) {
        groupedMap[key]!['gejala'].add(item['gejala_nama']);
      }

      // Simpan data detail untuk halaman detail
      groupedMap[key]!['detailData'].add(item);
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
    _totalPages = (filteredHistoriData.length / _rowsPerPage).ceil();

    int startIndex = page * _rowsPerPage;
    int endIndex = (page + 1) * _rowsPerPage;

    if (endIndex > filteredHistoriData.length) {
      endIndex = filteredHistoriData.length;
    }

    if (startIndex >= filteredHistoriData.length) {
      _currentPageData = [];
    } else {
      _currentPageData = filteredHistoriData.sublist(startIndex, endIndex);
    }
  }

  // Navigasi ke halaman detail
  void _navigateToDetail(Map<String, dynamic> histori) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailHistoriPage(histori: histori),
      ),
    );
  }

  // Function to pick date range
  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedFromDate != null && selectedToDate != null 
        ? DateTimeRange(start: selectedFromDate!, end: selectedToDate!)
        : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF9DC08D),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedFromDate = picked.start;
        selectedToDate = picked.end;
        // Reset month/year filter when date range is selected
        selectedMonth = 'Semua Bulan';
        selectedYear = 'Semua Tahun';
        _onDateFilterChanged();
      });
    }
  }

  // Function to clear date filter
  void _clearDateFilter() {
    setState(() {
      selectedFromDate = null;
      selectedToDate = null;
      selectedMonth = 'Semua Bulan';
      selectedYear = 'Semua Tahun';
      _onDateFilterChanged();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Histori User'),
        backgroundColor: Color(0xFF9DC08D),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : groupedHistoriData.isEmpty
          ? Center(child: Text('Tidak ada data riwayat diagnosa'))
          : Column(
              children: [
                // Search Bar
                Container(
                  margin: EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama user atau diagnosa...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF9DC08D),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF9DC08D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF9DC08D), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),

                // Date Filter Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Tanggal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9DC08D),
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Date Range Picker
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDateRange,
                              icon: Icon(Icons.date_range, size: 18),
                              label: Text(
                                selectedFromDate != null && selectedToDate != null
                                    ? '${DateFormat('dd/MM/yyyy').format(selectedFromDate!)} - ${DateFormat('dd/MM/yyyy').format(selectedToDate!)}'
                                    : 'Pilih Rentang Tanggal',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xFF9DC08D),
                                side: BorderSide(color: Color(0xFF9DC08D)),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (selectedFromDate != null || selectedToDate != null || 
                              selectedMonth != 'Semua Bulan' || selectedYear != 'Semua Tahun')
                            IconButton(
                              onPressed: _clearDateFilter,
                              icon: Icon(Icons.clear, size: 18),
                              tooltip: 'Hapus Filter',
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: 12),
                      Text('atau', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      SizedBox(height: 8),
                      
                      // Month and Year Dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedMonth,
                              decoration: InputDecoration(
                                labelText: 'Bulan',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                              items: months.map((month) {
                                return DropdownMenuItem<String>(
                                  value: month,
                                  child: Text(month, style: TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedMonth = value;
                                  // Clear date range when month/year is selected
                                  if (value != 'Semua Bulan') {
                                    selectedFromDate = null;
                                    selectedToDate = null;
                                  }
                                  _onDateFilterChanged();
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedYear,
                              decoration: InputDecoration(
                                labelText: 'Tahun',
                                labelStyle: TextStyle(fontSize: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                              items: years.map((year) {
                                return DropdownMenuItem<String>(
                                  value: year,
                                  child: Text(year, style: TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedYear = value;
                                  // Clear date range when month/year is selected
                                  if (value != 'Semua Tahun') {
                                    selectedFromDate = null;
                                    selectedToDate = null;
                                  }
                                  _onDateFilterChanged();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                Expanded(
                  child: filteredHistoriData.isEmpty && searchQuery.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada hasil untuk "${searchController.text}"',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Coba gunakan kata kunci yang berbeda',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _currentPageData.length,
                          itemBuilder: (context, index) {
                            final histori = _currentPageData[index];
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 12, left: 16, right: 16),
                              child: Row(
                                children: [
                                  // Card dengan informasi histori
                                  Expanded(
                                    child: Card(
                                      elevation: 2,
                                      child: InkWell(
                                        onTap: () => _navigateToDetail(histori),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Nama User
                                              Text(
                                                histori['userName'] ?? 'User tidak ditemukan',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              // Diagnosa
                                              Text(
                                                histori['diagnosa'] ?? 'Tidak ada diagnosa',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              // Tanggal
                                              Text(
                                                histori['tanggal_display'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // Button detail di luar card
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF9DC08D),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.info_outline, color: Colors.white),
                                      onPressed: () => _navigateToDetail(histori),
                                      tooltip: 'Lihat Detail',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Pagination controls
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.first_page, size: 18),
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() {
                                  _updatePagination(0);
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_left, size: 18),
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() {
                                  _updatePagination(_currentPage - 1);
                                });
                              }
                            : null,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${_currentPage + 1} / $_totalPages',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.chevron_right, size: 18),
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: _currentPage < _totalPages - 1
                            ? () {
                                setState(() {
                                  _updatePagination(_currentPage + 1);
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.last_page, size: 18),
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: _currentPage < _totalPages - 1
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
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rows per page: ',
                        style: TextStyle(fontSize: 12),
                      ),
                      DropdownButton<int>(
                        value: _rowsPerPage,
                        isDense: true,
                        menuMaxHeight: 200,
                        items: [10, 20, 50, 100].map((value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _rowsPerPage = value!;
                            _updatePagination(0);
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

// Halaman Detail Histori
class DetailHistoriPage extends StatelessWidget {
  final Map<String, dynamic> histori;

  const DetailHistoriPage({Key? key, required this.histori}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gabungkan semua gejala menjadi satu string
    String gejalaText = "Tidak ada gejala";
    if (histori['gejala'] != null && (histori['gejala'] as List).isNotEmpty) {
      gejalaText = (histori['gejala'] as List).join(', ');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Riwayat Diagnosa'),
        backgroundColor: Color(0xFF9DC08D),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF9DC08D).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Informasi Diagnosa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9DC08D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 20),

                // Nama User
                _buildDetailRow(
                  'Nama User',
                  histori['userName'] ?? 'User tidak ditemukan',
                  Icons.person,
                ),

                SizedBox(height: 16),

                // Tanggal Diagnosa
                _buildDetailRow(
                  'Tanggal Diagnosa',
                  histori['tanggal_display'] ?? '',
                  Icons.calendar_today,
                ),

                SizedBox(height: 16),

                // Diagnosa
                _buildDetailRow(
                  'Diagnosa',
                  histori['diagnosa'] ?? 'Tidak ada diagnosa',
                  Icons.medical_services,
                ),

                SizedBox(height: 16),

                // Hasil
                _buildDetailRow(
                  'Hasil',
                  _formatHasil(histori['hasil']),
                  Icons.analytics,
                ),

                SizedBox(height: 16),

                // Gejala
                _buildDetailSection(
                  'Gejala yang Dipilih',
                  gejalaText,
                  Icons.list_alt,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Color(0xFF9DC08D),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          ': ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? Colors.black87,
              fontWeight: valueColor != null ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Color(0xFF9DC08D),
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
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