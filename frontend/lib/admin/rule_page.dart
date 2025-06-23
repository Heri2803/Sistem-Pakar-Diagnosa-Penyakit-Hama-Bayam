import 'package:flutter/material.dart';
import 'package:SIBAYAM/admin/edit_rule_page.dart';
import 'package:http/http.dart' as http;
import 'package:SIBAYAM/api_services/api_services.dart';
import 'tambah_rule_page.dart';

class RulePage extends StatefulWidget {
  const RulePage({Key? key}) : super(key: key);

  @override
  _RulePageState createState() => _RulePageState();
}

class _RulePageState extends State<RulePage> {
  List<Map<String, dynamic>> gejalaList = [];
  List<Map<String, dynamic>> penyakitList = [];
  List<Map<String, dynamic>> hamaList = [];

  List<dynamic> rules = [];
  List<dynamic> filteredRules = [];
  bool isLoading = true;

  // Search and filter variables
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'Semua'; // 'Semua', 'Penyakit', 'Hama'

  // Pagination variables
  int currentPage = 0;
  int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchRules();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterRules();
  }

  void _filterRules() {
    setState(() {
      filteredRules = rules.where((rule) {
        // Filter berdasarkan kategori
        bool categoryMatch = true;
        if (selectedFilter == 'Penyakit') {
          categoryMatch = rule['id_penyakit'] != null;
        } else if (selectedFilter == 'Hama') {
          categoryMatch = rule['id_hama'] != null;
        }

        // Filter berdasarkan search text
        bool searchMatch = true;
        if (searchController.text.isNotEmpty) {
          final searchText = searchController.text.toLowerCase();
          final namaKategori = rule['id_penyakit'] != null
              ? (rule['nama_penyakit'] ?? '').toLowerCase()
              : (rule['nama_hama'] ?? '').toLowerCase();
          final namaGejala = (rule['nama_gejala'] ?? '').toLowerCase();
          
          searchMatch = namaKategori.contains(searchText) || 
                       namaGejala.contains(searchText);
        }

        return categoryMatch && searchMatch;
      }).toList();
      
      // Reset ke halaman pertama setelah filter
      currentPage = 0;
    });
  }

  void fetchRules() async {
    setState(() {
      isLoading = true;
    });

    final apiService = ApiService();

    try {
      // Ambil semua data referensi
      gejalaList = await apiService.getGejala();
      penyakitList = await apiService.getPenyakit();
      hamaList = await apiService.getHama();

      // Ambil rules penyakit dan hama secara terpisah
      final rulesPenyakit = await apiService.getRulesPenyakit();
      final rulesHama = await apiService.getRulesHama();

      // Gabungkan dan proses keduanya
      final enrichedRules = [
        // Mengolah rules penyakit
        ...rulesPenyakit.map((rule) {
          final gejala = gejalaList.firstWhere(
            (item) => item['id'] == rule['id_gejala'],
            orElse: () => {'nama': 'Gejala tidak ditemukan'},
          );

          final penyakit = penyakitList.firstWhere(
            (item) => item['id'] == rule['id_penyakit'],
            orElse: () => {'nama': 'Penyakit tidak ditemukan'},
          );

          return {
            'id': rule['id'],
            'id_gejala': rule['id_gejala'],
            'id_penyakit': rule['id_penyakit'],
            'id_hama': null,
            'nama_gejala': gejala['nama'],
            'nama_penyakit': penyakit['nama'],
            'nama_hama': null,
            'nilai_pakar': rule['nilai_pakar'],
            'type': 'Penyakit',
          };
        }),
        // Mengolah rules hama
        ...rulesHama.map((rule) {
          final gejala = gejalaList.firstWhere(
            (item) => item['id'] == rule['id_gejala'],
            orElse: () => {'nama': 'Gejala tidak ditemukan'},
          );

          final hama = hamaList.firstWhere(
            (item) => item['id'] == rule['id_hama'],
            orElse: () => {'nama': 'Hama tidak ditemukan'},
          );

          return {
            'id': rule['id'],
            'id_gejala': rule['id_gejala'],
            'id_penyakit': null,
            'id_hama': rule['id_hama'],
            'nama_gejala': gejala['nama'],
            'nama_penyakit': null,
            'nama_hama': hama['nama'],
            'nilai_pakar': rule['nilai_pakar'],
            'type': 'Hama',
          };
        }),
      ];

      setState(() {
        rules = enrichedRules;
        filteredRules = enrichedRules;
      });
    } catch (e) {
      print('Terjadi kesalahan saat memuat data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteRule(Map<String, dynamic> rule) async {
    // Tampilkan dialog konfirmasi
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus rule ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      http.Response res;

      // Tentukan fungsi delete berdasarkan isi rule
      if (rule['id_hama'] != null) {
        res = await ApiService.deleteRuleHama(rule['id']);
      } else if (rule['id_penyakit'] != null) {
        res = await ApiService.deleteRulePenyakit(rule['id']);
      } else {
        throw Exception("Data rule tidak valid");
      }

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Rule berhasil dihapus"),
            backgroundColor: Colors.green,
          ),
        );
        fetchRules(); // Refresh data setelah delete
      } else {
        throw Exception("Gagal menghapus rule");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan saat menghapus: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get paginated data
  List<dynamic> get paginatedRules {
    final startIndex = currentPage * rowsPerPage;
    final endIndex = startIndex + rowsPerPage > filteredRules.length 
        ? filteredRules.length 
        : startIndex + rowsPerPage;
    
    if (startIndex >= filteredRules.length) {
      return [];
    }
    
    return filteredRules.sublist(startIndex, endIndex);
  }

  Widget _buildSearchAndFilter() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced from 16.0
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama penyakit, hama, atau gejala...',
                      prefixIcon: Icon(Icons.search, size: 20), // Reduced icon size
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Reduced padding
                      isDense: true, // Makes the field more compact
                    ),
                    style: TextStyle(fontSize: 14), // Reduced font size
                  ),
                ),
                SizedBox(width: 12), // Reduced from 16
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFilter,
                    decoration: InputDecoration(
                      labelText: 'Filter Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Reduced padding
                      isDense: true, // Makes the field more compact
                    ),
                    style: TextStyle(fontSize: 14, color: Colors.black), // Reduced font size
                    items: ['Semua', 'Penyakit', 'Hama'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 14)), // Consistent font size
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilter = newValue!;
                        _filterRules();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12), // Reduced from 16
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${filteredRules.length} rule(s)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    fontSize: 13, // Reduced font size
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TambahRulePage(
                              isEditing: false,
                              isEditingHama: true,
                              selectedRuleIds: [],
                              selectedGejalaIds: [],
                              nilaiPakarList: [],
                              selectedHamaId: null,
                              selectedPenyakitId: null,
                              showHamaOnly: true,
                            ),
                          ),
                        ).then((_) => fetchRules());
                      },
                      icon: Icon(Icons.bug_report, size: 14), // Reduced from 16
                      label: Text("Rule Hama", style: TextStyle(fontSize: 11)), // Reduced from 12
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Reduced padding
                        minimumSize: Size(0, 32), // Reduced from 36
                      ),
                    ),
                    SizedBox(width: 6), // Reduced from 8
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TambahRulePage(
                              isEditing: false,
                              isEditingHama: false,
                              selectedRuleIds: [],
                              selectedGejalaIds: [],
                              nilaiPakarList: [],
                              selectedHamaId: null,
                              selectedPenyakitId: null,
                              showPenyakitOnly: true,
                            ),
                          ),
                        ).then((_) => fetchRules());
                      },
                      icon: Icon(Icons.healing, size: 14), // Reduced from 16
                      label: Text("Rule Penyakit", style: TextStyle(fontSize: 11)), // Reduced from 12
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Reduced padding
                        minimumSize: Size(0, 32), // Reduced from 36
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList() {
    if (paginatedRules.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Tidak ada data rule',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (searchController.text.isNotEmpty || selectedFilter != 'Semua')
              TextButton(
                onPressed: () {
                  setState(() {
                    searchController.clear();
                    selectedFilter = 'Semua';
                    _filterRules();
                  });
                },
                child: Text('Reset Filter'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: paginatedRules.length,
      itemBuilder: (context, index) {
        final rule = paginatedRules[index];
        
        final namaKategori = rule['id_penyakit'] != null
            ? rule['nama_penyakit'] ?? '-'
            : rule['nama_hama'] ?? '-';

        final kategori = rule['type'] ?? 'Unknown';
        final isHama = rule['id_hama'] != null;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Card dengan data rule
              Expanded(
                child: Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _navigateToEdit(rule),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kategori badge dan nama
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isHama ? Colors.green[100] : Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  kategori,
                                  style: TextStyle(
                                    color: isHama ? Colors.green[800] : Colors.blue[800],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  namaKategori,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Gejala
                          Text(
                            'Gejala: ${rule['nama_gejala'] ?? '-'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          // Nilai pakar
                          Row(
                            children: [
                              Text(
                                'Nilai Pakar: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF9DC08D),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  rule['nilai_pakar']?.toString() ?? '-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Button hapus di luar card
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () => deleteRule(rule),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToEdit(Map<String, dynamic> rule) {
    if (rule != null &&
        rule['id'] != null &&
        rule['id_gejala'] != null &&
        rule['nilai_pakar'] != null) {
      final bool editingHama = rule['id_hama'] != null;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditRulePage(
            isEditing: true,
            isEditingHama: editingHama,
            selectedRuleIds: [rule['id'] as int],
            selectedGejalaIds: [rule['id_gejala'] as int],
            nilaiPakarList: [(rule['nilai_pakar'] as num).toDouble()],
            selectedHamaId: rule['id_hama'] as int?,
            selectedPenyakitId: rule['id_penyakit'] as int?,
            showHamaOnly: editingHama,
            showPenyakitOnly: !editingHama,
          ),
        ),
      ).then((_) => fetchRules());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data rule tidak lengkap"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPaginationControls() {
    final totalPages = (filteredRules.length / rowsPerPage).ceil();
    
    if (totalPages <= 1) return SizedBox.shrink();

    return Card(
      elevation: 1,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '${(currentPage * rowsPerPage) + 1}-${((currentPage + 1) * rowsPerPage > filteredRules.length) ? filteredRules.length : (currentPage + 1) * rowsPerPage} / ${filteredRules.length}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.first_page, size: 18),
                  onPressed: currentPage > 0
                      ? () => setState(() => currentPage = 0)
                      : null,
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_left, size: 18),
                  onPressed: currentPage > 0
                      ? () => setState(() => currentPage--)
                      : null,
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    '${currentPage + 1}/$totalPages',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, size: 18),
                  onPressed: (currentPage + 1) * rowsPerPage < filteredRules.length
                      ? () => setState(() => currentPage++)
                      : null,
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.last_page, size: 18),
                  onPressed: (currentPage + 1) * rowsPerPage < filteredRules.length
                      ? () => setState(() => currentPage = totalPages - 1)
                      : null,
                  padding: EdgeInsets.all(4),
                  constraints: BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Aturan'),
        backgroundColor: Color(0xFF9DC08D),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchAndFilter(),
                  SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _buildDataList()),
                        SizedBox(height: 8),
                        _buildPaginationControls(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}