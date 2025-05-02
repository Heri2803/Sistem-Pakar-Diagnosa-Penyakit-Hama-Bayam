import 'package:flutter/material.dart';
import 'package:frontend/admin/edit_rule_page.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/api_services/api_services.dart';
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
            'nilai_pakar':
                rule['nilai_pakar'], // Menambahkan nilai_pakar dari rule_penyakit
          };
        }),
        // Mengolah rules hama
        ...rulesHama.map((rule) {
          print(
            "Rule id_gejala: ${rule['id_gejala']}, id_hama: ${rule['id_hama']}",
          );

          // Mencari gejala berdasarkan id
          final gejala = gejalaList.firstWhere((item) {
            print(
              "Mencocokkan gejala id: ${item['id']} dengan ${rule['id_gejala']}",
            );
            return item['id'] == rule['id_gejala'];
          }, orElse: () => {'nama': 'TIDAK DITEMUKAN'});

          // Mencari hama berdasarkan id
          final hama = hamaList.firstWhere(
            (item) => item['id'] == rule['id_hama'],
            orElse: () => {'nama': 'TIDAK DITEMUKAN'},
          );

          print(
            "Gejala ditemukan: ${gejala['nama']}, Hama ditemukan: ${hama['nama']}",
          );

          // Menampilkan isi dari gejalaList dan hamaList untuk debugging
          print("Isi gejalaList:");
          for (var item in gejalaList) {
            print(item);
          }

          print("Isi hamaList:");
          for (var item in hamaList) {
            print(item);
          }

          return {
            'id': rule['id'],
            'id_gejala': rule['id_gejala'],
            'id_penyakit': null,
            'id_hama': rule['id_hama'],
            'nama_gejala': gejala['nama'], // Memastikan nama gejala ditampilkan
            'nama_penyakit': null,
            'nama_hama': hama['nama'], // Memastikan nama hama ditampilkan
            'nilai_pakar':
                rule['nilai_pakar'], // Menambahkan nilai_pakar dari rule_hama
          };
        }),
      ];

      setState(() {
        rules = enrichedRules;
      });
    } catch (e) {
      print('Terjadi kesalahan saat memuat data: $e');
      for (var rule in rules) {
        print("Mencari gejala untuk id_gejala: ${rule['id_gejala']}");
        var gejala = gejalaList.firstWhere(
          (item) => item['id'].toString() == rule['id_gejala'].toString(),
          orElse: () => {'nama': 'TIDAK DITEMUKAN'},
        );
        print("Gejala ditemukan: ${gejala['nama']}");
      }
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
        res = await ApiService.deleteRuleHama(
          rule['id'],
        ); // Fungsi API untuk delete hama
      } else if (rule['id_penyakit'] != null) {
        res = await ApiService.deleteRulePenyakit(
          rule['id'],
        ); // Fungsi API untuk delete penyakit
      } else {
        throw Exception(
          "Data rule tidak valid (tidak ada id_hama atau id_penyakit)",
        );
      }

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Rule berhasil dihapus")));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Rules')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TambahRulePage(
                            isEditing: false, // Menandakan mode tambah
                            isEditingHama:
                                true, // Atur sesuai dengan jenis rule
                            selectedRuleIds: [],
                            selectedGejalaIds: [],
                            nilaiPakarList: [],
                            selectedHamaId: null, // Hanya jika rule hama
                            selectedPenyakitId:
                                null, // Hanya jika rule penyakit
                          ),
                    ),
                  ).then((_) => fetchRules());
                },
                icon: Icon(Icons.add),
                label: Text("Tambah Rule"),
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Hama / Penyakit')),
                        DataColumn(label: Text('Gejala')),
                        DataColumn(label: Text('nilai pakar')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: List.generate(rules.length, (index) {
                        final rule = rules[index];

                        final namaKategori =
                            rule['id_penyakit'] != null
                                ? rule['nama_penyakit'] ?? '-'
                                : rule['nama_hama'] ?? '-';

                        final isPenyakit = rule['id_penyakit'] != null;

                        return DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(namaKategori)),
                            DataCell(Text(rule['nama_gejala'] ?? '-')),
                            DataCell(
                              Text(rule['nilai_pakar']?.toString() ?? '-'),
                            ),
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => EditRulePage(
                                                  isEditing: true,
                                                  isEditingHama: true,
                                                  selectedRuleIds: [
                                                    rule['id'] as int,
                                                  ],
                                                  selectedGejalaIds: [
                                                    rule['id_gejala'] as int,
                                                  ],
                                                  nilaiPakarList: [
                                                    (rule['nilai_pakar'] as num)
                                                        .toDouble(),
                                                  ],
                                                  selectedHamaId:
                                                      rule['id_hama']
                                                          as int?,
                                                  selectedPenyakitId: rule['id_penyakit'] as int?, // Tambahkan type cast ke int?
                                                ),
                                          ),
                                        );
                                      } else {
                                        // Tampilkan pesan error jika data rule tidak lengkap
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Data rule tidak lengkap atau tidak valid",
                                            ),
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
          ],
        ),
      ),
    );
  }
}
