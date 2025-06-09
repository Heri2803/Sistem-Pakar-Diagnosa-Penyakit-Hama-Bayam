import 'package:flutter/material.dart';
import 'package:SIBAYAM/admin/edit_rule_page.dart';
import 'package:http/http.dart' as http;
import 'package:SIBAYAM/api_services/api_services.dart';
import 'tambah_rule_page.dart';
import 'edit_hama_page.dart';

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
  bool isLoading = true;

  // Pagination variables
  int currentPage = 0;
  int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchRules();
  }

  void fetchRules() async {
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
            orElse: () => {'nama': '-'},
          );

          final penyakit = penyakitList.firstWhere(
            (item) => item['id'] == rule['id_penyakit'],
            orElse: () => {'nama': '-'},
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
          };
        }),
        // Mengolah rules hama
        ...rulesHama.map((rule) {
          // Mencari gejala berdasarkan id
          final gejala = gejalaList.firstWhere(
            (item) => item['id'] == rule['id_gejala'],
            orElse: () => {'nama': 'TIDAK DITEMUKAN'},
          );

          // Mencari hama berdasarkan id
          final hama = hamaList.firstWhere(
            (item) => item['id'] == rule['id_hama'],
            orElse: () => {'nama': 'TIDAK DITEMUKAN'},
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
          };
        }),
      ];

      setState(() {
        rules = enrichedRules;
      });
    } catch (e) {
      print('Terjadi kesalahan saat memuat data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteRule(Map<String, dynamic> rule) async {
    try {
      http.Response res;

      // Tentukan fungsi delete berdasarkan isi rule
      if (rule['id_hama'] != null) {
        res = await ApiService.deleteRuleHama(rule['id']); // Fungsi API untuk delete hama
      } else if (rule['id_penyakit'] != null) {
        res = await ApiService.deleteRulePenyakit(rule['id']); // Fungsi API untuk delete penyakit
      } else {
        throw Exception("Data rule tidak valid (tidak ada id_hama atau id_penyakit)");
      }

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Rule berhasil dihapus"))
        );
        fetchRules(); // Refresh data setelah delete
      } else {
        throw Exception("Gagal menghapus rule");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan saat menghapus: $e")),
      );
    }
  }

  // Get paginated data
  List<dynamic> get paginatedRules {
    final startIndex = currentPage * rowsPerPage;
    final endIndex = startIndex + rowsPerPage > rules.length ? rules.length : startIndex + rowsPerPage;
    
    if (startIndex >= rules.length) {
      return [];
    }
    
    return rules.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Rules'), backgroundColor: Color(0xFF9DC08D)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Button untuk tambah rule hama
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TambahRulePage(
                          isEditing: false,
                          isEditingHama: true, // Menandakan ini adalah rule hama
                          selectedRuleIds: [],
                          selectedGejalaIds: [],
                          nilaiPakarList: [],
                          selectedHamaId: null,
                          selectedPenyakitId: null,
                          showHamaOnly: true, // Parameter baru untuk menampilkan hanya dropdown hama
                        ),
                      ),
                    ).then((_) => fetchRules());
                  },
                  icon: Icon(Icons.bug_report, size: 16,),
                  label: Text(
                    "Tambah Rule Hama",
                    style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Padding lebih kecil
                    minimumSize: Size(0, 32), // Tinggi minimum lebih kecil
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Mengurangi area tap
                  ),
                ),
                SizedBox(width: 10),
                // Button untuk tambah rule penyakit
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TambahRulePage(
                          isEditing: false,
                          isEditingHama: false, // Menandakan ini adalah rule penyakit
                          selectedRuleIds: [],
                          selectedGejalaIds: [],
                          nilaiPakarList: [],
                          selectedHamaId: null,
                          selectedPenyakitId: null,
                          showPenyakitOnly: true, // Parameter baru untuk menampilkan hanya dropdown penyakit
                        ),
                      ),
                    ).then((_) => fetchRules());
                  },
                  icon: Icon(Icons.healing, size: 16,),
                  label: Text(
                    "Tambah Rule Penyakit",
                    style: TextStyle(fontSize: 12),),
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Padding lebih kecil
                    minimumSize: Size(0, 32), // Tinggi minimum lebih kecil
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Mengurangi area tap
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  return Color(0xFF9DC08D); // Apply color to all header rows
                                },
                              ),
                              columns: const [
                                DataColumn(label: Text('No')),
                                DataColumn(label: Text('Hama & Penyakit')),
                                DataColumn(label: Text('Gejala')),
                                DataColumn(label: Text('Nilai Pakar')),
                                DataColumn(label: Text('Aksi')),
                              ],
                              rows: List.generate(paginatedRules.length, (index) {
                                final rule = paginatedRules[index];
                                final displayIndex = currentPage * rowsPerPage + index + 1;

                                final namaKategori = rule['id_penyakit'] != null
                                    ? rule['nama_penyakit'] ?? '-'
                                    : rule['nama_hama'] ?? '-';

                                final isPenyakit = rule['id_penyakit'] != null;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(displayIndex.toString())),
                                    DataCell(Text(namaKategori)),
                                    DataCell(Text(rule['nama_gejala'] ?? '-')),
                                    DataCell(Text(rule['nilai_pakar']?.toString() ?? '-')),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                            ),
                                            onPressed: () {
                                              if (rule != null &&
                                                  rule['id'] != null &&
                                                  rule['id_gejala'] != null &&
                                                  rule['nilai_pakar'] != null) {
                                                // Tentukan jenis rule untuk editing
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
                                                      // Tambahkan parameter untuk menentukan dropdown yang ditampilkan
                                                      showHamaOnly: editingHama,
                                                      showPenyakitOnly: !editingHama,
                                                    ),
                                                  ),
                                                ).then((_) => fetchRules());
                                              } else {
                                                // Tampilkan pesan error jika data rule tidak lengkap
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Data rule tidak lengkap atau tidak valid"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                // Debug info
                                                print("Rule data: $rule");
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              deleteRule(rule);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                        ),
                        // Pagination controls
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.chevron_left),
                                onPressed: currentPage > 0
                                    ? () => setState(() => currentPage--)
                                    : null,
                              ),
                              Text('Halaman ${currentPage + 1} dari ${(rules.length / rowsPerPage).ceil()}'),
                              IconButton(
                                icon: Icon(Icons.chevron_right),
                                onPressed: (currentPage + 1) * rowsPerPage < rules.length
                                    ? () => setState(() => currentPage++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}