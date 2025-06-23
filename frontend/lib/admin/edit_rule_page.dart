import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
import 'package:http/http.dart' as http;

class EditRulePage extends StatefulWidget {
  @override
  _EditRulePageState createState() => _EditRulePageState();

  final bool isEditing;
  final bool isEditingHama;
  final List<int> selectedRuleIds;
  final List<int> selectedGejalaIds;
  final List<double> nilaiPakarList;
  final int? selectedHamaId;
  final int? selectedPenyakitId;
  final bool showHamaOnly; // Tambahkan ini
  final bool showPenyakitOnly; // Tambahkan ini

  const EditRulePage({
    Key? key,
    required this.isEditing,
    required this.isEditingHama,
    required this.selectedRuleIds,
    required this.selectedGejalaIds,
    required this.nilaiPakarList,
    this.showHamaOnly = false, // Tambahkan default value
    this.showPenyakitOnly = false,
    this.selectedHamaId,
    this.selectedPenyakitId,
  }) : super(key: key);
}

class _EditRulePageState extends State<EditRulePage> {
  int? selectedHamaId;
  int? selectedPenyakitId;
  List<int?> selectedGejalaIds = [null];
  List<double> nilaiPakarList = [0.5];
  List<int?> selectedRuleIds = [];

  bool isEditing = true; // atau false jika sedang edit penyakit

  bool isLoading = true;

  bool showHamaOnly = false;
  bool showPenyakitOnly = false;

  final api = ApiService();

  // Deklarasi variabel untuk menampung data dari API
  List<Map<String, dynamic>> hamaList = [];
  List<Map<String, dynamic>> penyakitList = [];
  List<Map<String, dynamic>> gejalaList = [];

  void loadRulesForEditing() async {
    try {
      final fetchedRules =
          isEditing ? await api.getRulesHama() : await api.getRulesPenyakit();

      print('Fetched Rules: $fetchedRules');

      // Filter data yang valid dan konversi dengan aman
      final validRules =
          fetchedRules.where((rule) {
            if (rule is Map<String, dynamic>) {
              // Pastikan semua key yang diperlukan ada dan nilainya tidak null
              return rule.containsKey('id') &&
                  rule.containsKey('id_gejala') &&
                  rule.containsKey('nilai_pakar') &&
                  (rule.containsKey('id_penyakit') ||
                      rule.containsKey('id_hama')) &&
                  rule['id'] != null &&
                  rule['id_gejala'] != null &&
                  rule['nilai_pakar'] != null &&
                  (rule['id_penyakit'] != null || rule['id_hama'] != null);
            }
            return false;
          }).toList();

      // Pastikan konversi tipe data dilakukan dengan aman
      setState(() {
        selectedRuleIds =
            validRules.map<int?>((rule) {
              // Pastikan id bisa dikonversi ke int
              final id = rule['id'];
              return id is int ? id : (id is String ? int.tryParse(id) : null);
            }).toList();

        selectedGejalaIds =
            validRules.map<int?>((rule) {
              // Pastikan id_gejala bisa dikonversi ke int
              final idGejala = rule['id_gejala'];
              return idGejala is int
                  ? idGejala
                  : (idGejala is String ? int.tryParse(idGejala) : null);
            }).toList();

        nilaiPakarList =
            validRules.map<double>((rule) {
              // Pastikan nilai_pakar bisa dikonversi ke double
              final nilaiPakar = rule['nilai_pakar'];
              if (nilaiPakar is double) return nilaiPakar;
              if (nilaiPakar is int) return nilaiPakar.toDouble();
              if (nilaiPakar is String)
                return double.tryParse(nilaiPakar) ?? 0.5;
              return 0.5; // Nilai default
            }).toList();

        print('Valid Rules: $validRules');
        print('selectedRuleIds: $selectedRuleIds');
        print('selectedGejalaIds: $selectedGejalaIds');
        print('nilaiPakarList: $nilaiPakarList');
      });
    } catch (e) {
      print("Gagal memuat data rule: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data rule: $e")));
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
    showHamaOnly = widget.showHamaOnly;
    showPenyakitOnly = widget.showPenyakitOnly;
    fetchData(); // Panggil fetchData saat halaman dibuka pertama kali

    // Inisialisasi dari widget parent
    if (widget.isEditing) {
      selectedHamaId = widget.selectedHamaId;
      selectedPenyakitId = widget.selectedPenyakitId;

      // Copy nilai dari widget ke state
      if (widget.selectedRuleIds.isNotEmpty) {
        selectedRuleIds = List<int?>.from(widget.selectedRuleIds);
      }
      if (widget.selectedGejalaIds.isNotEmpty) {
        selectedGejalaIds = List<int?>.from(widget.selectedGejalaIds);
      }
      if (widget.nilaiPakarList.isNotEmpty) {
        nilaiPakarList = List<double>.from(widget.nilaiPakarList);
      }
    }
  }

  void updateRules() async {
    if (selectedRuleIds.length != selectedGejalaIds.length ||
        selectedRuleIds.length != nilaiPakarList.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data rule tidak sinkron. Silakan cek kembali."),
        ),
      );
      return;
    }

    try {
      for (int i = 0; i < selectedGejalaIds.length; i++) {
        final idRule = selectedRuleIds[i];
        final idGejala = selectedGejalaIds[i];
        final nilai = nilaiPakarList[i];

        if (idRule == null || idGejala == null) {
          print("Lewat karena data null pada index ke-$i");
          continue;
        }

        http.Response response;

        if (selectedPenyakitId != null) {
          response = await ApiService.updateRulePenyakit(
            id: idRule,
            idGejala: idGejala,
            idPenyakit: selectedPenyakitId!,
            nilaiPakar: nilai,
          );
        } else {
          response = await ApiService.updateRuleHama(
            id: idRule,
            idGejala: idGejala,
            idHama: selectedHamaId!,
            nilaiPakar: nilai,
          );
        }

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception("Gagal mengupdate rule");
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Data berhasil diperbarui")));
      Navigator.pop(context);
    } catch (e) {
      print('Gagal memperbarui data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memperbarui data")));
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
                        if (!showPenyakitOnly) ...[
                          Text("Pilih Hama"),
                          DropdownButton<int>(
                            isExpanded: true,
                            value: selectedHamaId,
                            hint: Text('Pilih Hama'),
                            items:
                                hamaList.isNotEmpty
                                    ? hamaList.map<DropdownMenuItem<int>>((
                                      hama,
                                    ) {
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
                        ],

                        // Pilih Penyakit
                        if (!showHamaOnly) ...[
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
                        ],

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
                                    child: StatefulBuilder(
                                      // Gunakan ini untuk menghindari pembuatan controller terus-menerus di build
                                      builder: (context, setLocalState) {
                                        final controller =
                                            TextEditingController(
                                              text:
                                                  nilaiPakarList.length > index
                                                      ? nilaiPakarList[index]
                                                          .toString()
                                                      : "0.5",
                                            );
                                        return TextField(
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          controller: controller,
                                          decoration: InputDecoration(
                                            labelText: "Nilai Pakar",
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              double parsedValue =
                                                  double.tryParse(value) ?? 0.5;

                                              // Cek apakah nilai lebih dari 1
                                              if (parsedValue > 1) {
                                                // Tampilkan dialog peringatan
                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return AlertDialog(
                                                      title: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.warning,
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text("Peringatan"),
                                                        ],
                                                      ),
                                                      content: Text(
                                                        "Nilai yang diisi maksimal 1",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                            // Reset nilai setelah dialog ditutup
                                                            String
                                                            previousValue =
                                                                nilaiPakarList
                                                                            .length >
                                                                        index
                                                                    ? nilaiPakarList[index]
                                                                        .toString()
                                                                    : "0.5";
                                                            controller.text =
                                                                previousValue;
                                                            controller
                                                                    .selection =
                                                                TextSelection.fromPosition(
                                                                  TextPosition(
                                                                    offset:
                                                                        controller
                                                                            .text
                                                                            .length,
                                                                  ),
                                                                );
                                                          },
                                                          child: Text("OK"),
                                                        ),
                                                      ],
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                );

                                                return; // Keluar dari fungsi tanpa menyimpan nilai
                                              }

                                              // Simpan nilai jika valid (≤ 1)
                                              setState(() {
                                                if (nilaiPakarList.length <=
                                                    index) {
                                                  nilaiPakarList.add(
                                                    parsedValue,
                                                  );
                                                } else {
                                                  nilaiPakarList[index] =
                                                      parsedValue;
                                                }
                                              });
                                            }
                                          },
                                        );
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

                        // Tombol untuk edit rule
                        ElevatedButton(
                          onPressed: () {
                            // Panggil fungsi saveRules untuk menyimpan data
                            updateRules();
                          },
                          child: Text('Perbarui Rule'),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
