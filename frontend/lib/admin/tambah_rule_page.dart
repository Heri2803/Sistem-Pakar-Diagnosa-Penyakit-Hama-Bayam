import 'package:flutter/material.dart';
import 'package:frontend/api_services/api_services.dart';
import 'package:http/http.dart' as http;

class TambahRulePage extends StatefulWidget {
  @override
  _TambahRulePageState createState() => _TambahRulePageState();

  final bool isEditing;
  final bool isEditingHama;
  final List<int> selectedRuleIds;
  final List<int> selectedGejalaIds;
  final List<double> nilaiPakarList;
  final int? selectedHamaId;
  final int? selectedPenyakitId;

  const TambahRulePage({
    Key? key,
    required this.isEditing,
    required this.isEditingHama,
    required this.selectedRuleIds,
    required this.selectedGejalaIds,
    required this.nilaiPakarList,
    this.selectedHamaId,
    this.selectedPenyakitId,
  }) : super(key: key);
}

class _TambahRulePageState extends State<TambahRulePage> {
  
  int? selectedHamaId;
  int? selectedPenyakitId;
  List<int?> selectedGejalaIds = [null];
  List<double> nilaiPakarList = [0.5];
  List<int?> selectedRuleIds = []; // List paralel dengan selectedGejalaIds dan nilaiPakarList

  bool isEditing = true; // atau false jika sedang edit penyakit

  bool isLoading = true;

  final api = ApiService();

  // Deklarasi variabel untuk menampung data dari API
  List<Map<String, dynamic>> hamaList = [];
  List<Map<String, dynamic>> penyakitList = [];
  List<Map<String, dynamic>> gejalaList = [];

  void loadRulesForEditing() async {
  try {
    final fetchedRules = isEditing
        ? await api.getRulesHama()
        : await api.getRulesPenyakit();

    setState(() {
      selectedRuleIds = fetchedRules.map<int>((rule) => rule['id']).toList();
      selectedGejalaIds = fetchedRules.map<int>((rule) => rule['id_gejala']).toList();
      nilaiPakarList = fetchedRules.map<double>((rule) => (rule['nilai_pakar'] as num).toDouble()).toList();
    });
  } catch (e) {
    print("Gagal memuat data rule: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal memuat data rule")),
    );
  }
}


  // Fungsi untuk fetch data dari API
  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // Mengatur status loading saat mulai ambil data
    });

    try {
      // Ambil data dari API
      final hamaData = await api.getHama();
      final penyakitData = await api.getPenyakit();
      final gejalaData = await api.getGejala();

      // Debugging: Cek apakah data yang diterima dari API
      print("Hama Data: $hamaData");
      print("Penyakit Data: $penyakitData");
      print("Gejala Data: $gejalaData");

      // Pengecekan jika data kosong
      if (hamaData.isEmpty || penyakitData.isEmpty || gejalaData.isEmpty) {
        print("Data kosong, periksa API atau koneksi.");
      }

      // Update data dan status loading
      setState(() {
        hamaList = hamaData;
        penyakitList = penyakitData;
        gejalaList = gejalaData;
        isLoading = false; // Mengubah status loading setelah data diterima
      });
    } catch (e) {
      // Menangani error jika fetch gagal
      print("Error fetching data: $e");

      setState(() {
        isLoading =
            false; // Mengubah status loading selesai meskipun terjadi error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Panggil fetchData saat halaman dibuka pertama kali
  }

  void saveRules() async {
    if (selectedPenyakitId == null && selectedHamaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pilih minimal satu: Penyakit atau Hama")),
      );
      return;
    }

    try {
      for (int i = 0; i < selectedGejalaIds.length; i++) {
        final idGejala = selectedGejalaIds[i];
        final nilai = nilaiPakarList[i];

        if (idGejala != null) {
          if (selectedPenyakitId != null) {
            final response = await ApiService.createRulePenyakit(
              idGejala: idGejala,
              idPenyakit: selectedPenyakitId,
              nilaiPakar: nilai,
            );

            if (response.statusCode != 200 && response.statusCode != 201) {
              throw Exception("Gagal menyimpan rule penyakit");
            }
          } else if (selectedHamaId != null) {
            final response = await ApiService.createRuleHama(
              idGejala: idGejala,
              idHama: selectedHamaId,
              nilaiPakar: nilai,
            );

            if (response.statusCode != 200 && response.statusCode != 201) {
              throw Exception("Gagal menyimpan rule hama");
            }
          }
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Data berhasil disimpan")));

      Navigator.pop(context);
    } catch (e) {
      print('Gagal menyimpan data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data")));
    }
  }

  void updateRules() async {
  if (selectedPenyakitId == null && selectedHamaId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pilih minimal satu: Penyakit atau Hama")),
    );
    return;
  }

  try {
    for (int i = 0; i < selectedGejalaIds.length; i++) {
      final idRule = selectedRuleIds[i];
      final idGejala = selectedGejalaIds[i];
      final nilai = nilaiPakarList[i];

      if (idRule != null && idGejala != null) {
        http.Response response;

        if (selectedPenyakitId != null) {
          response = await ApiService.updateRulePenyakit(
            id: idRule,
            idGejala: idGejala,
            idPenyakit: selectedPenyakitId,
            nilaiPakar: nilai,
          );
        } else {
          response = await ApiService.updateRuleHama(
            id: idRule,
            idGejala: idGejala,
            idHama: selectedHamaId,
            nilaiPakar: nilai,
          );
        }

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception("Gagal mengupdate rule");
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data berhasil diperbarui")),
    );
    Navigator.pop(context);
  } catch (e) {
    print('Gagal memperbarui data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal memperbarui data")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Rule")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        // Pilih Hama
                        Text("Pilih Hama"),
                        DropdownButton<int>(
                          isExpanded: true,
                          value: selectedHamaId,
                          hint: Text('Pilih Hama'),
                          items:
                              hamaList.isNotEmpty
                                  ? hamaList.map<DropdownMenuItem<int>>((hama) {
                                    return DropdownMenuItem<int>(
                                      value: hama['id'],
                                      child: Text(hama['nama']),
                                    );
                                  }).toList()
                                  : [
                                    DropdownMenuItem<int>(
                                      value: null,
                                      child: Text("Data tidak tersedia"),
                                    ),
                                  ],
                          onChanged: (value) {
                            setState(() {
                              selectedHamaId = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        // Pilih Penyakit
                        Text("Pilih Penyakit"),
                        DropdownButton<int>(
                          isExpanded: true,
                          value: selectedPenyakitId,
                          hint: Text('Pilih Penyakit'),
                          items:
                              penyakitList.isNotEmpty
                                  ? penyakitList.map<DropdownMenuItem<int>>((
                                    penyakit,
                                  ) {
                                    return DropdownMenuItem<int>(
                                      value: penyakit['id'],
                                      child: Text(penyakit['nama']),
                                    );
                                  }).toList()
                                  : [
                                    DropdownMenuItem<int>(
                                      value: null,
                                      child: Text("Data tidak tersedia"),
                                    ),
                                  ],
                          onChanged: (value) {
                            setState(() {
                              selectedPenyakitId = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        // Pilih Gejala dan Nilai Pakar
                        Text("Pilih Gejala"),
                        ...List.generate(
                          selectedGejalaIds.length,
                          (index) => Card(
                            elevation: 3,
                            margin: EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // Dropdown untuk gejala
                                  Expanded(
                                    child: DropdownButton<int>(
                                      isExpanded: true,
                                      value: selectedGejalaIds[index],
                                      hint: Text('Pilih Gejala'),
                                      items:
                                          gejalaList.isNotEmpty
                                              ? gejalaList.map<
                                                DropdownMenuItem<int>
                                              >((gejala) {
                                                return DropdownMenuItem<int>(
                                                  value: gejala['id'],
                                                  child: Text(gejala['nama']),
                                                );
                                              }).toList()
                                              : [
                                                DropdownMenuItem<int>(
                                                  value: null,
                                                  child: Text(
                                                    "Data tidak tersedia",
                                                  ),
                                                ),
                                              ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGejalaIds[index] = value;
                                        });
                                      },
                                    ),
                                  ),

                                  // Input nilai pakar
                                  SizedBox(width: 16),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Nilai Pakar",
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value.isNotEmpty) {
                                            nilaiPakarList[index] =
                                                double.tryParse(value) ?? 0.5;
                                          }
                                        });
                                      },
                                    ),
                                  ),

                                  // Tombol untuk menghapus gejala
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        selectedGejalaIds.removeAt(index);
                                        nilaiPakarList.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Tombol untuk menambah gejala
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedGejalaIds.add(null);
                              nilaiPakarList.add(
                                0.5,
                              ); // Menambahkan nilai pakar default
                            });
                          },
                          child: Text('Tambah Gejala'),
                        ),

                        SizedBox(height: 20),

                        // Tombol untuk menambah rule
                        ElevatedButton(
                          onPressed: () {
                            // Panggil fungsi saveRules untuk menyimpan data
                            saveRules();
                          },
                          child: Text('Tambah Rule'),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
