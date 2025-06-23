import 'package:flutter/material.dart';
import 'hasil_diagnosa_page.dart';
import 'package:SIBAYAM/api_services/api_services.dart';

class DiagnosaPage extends StatefulWidget {
  @override
  _DiagnosaPageState createState() => _DiagnosaPageState();
}

class _DiagnosaPageState extends State<DiagnosaPage> {
  List<Map<String, dynamic>> gejalaList = [];
  List<Map<String, dynamic>> filteredGejalaList = []; // Untuk hasil pencarian
  List<String> gejalaTerpilihIds = []; // Menyimpan ID gejala
  List<String> gejalaTerpilihNames = []; // Menyimpan nama gejala untuk tampilan
  bool isLoading = true;
  
  // Controller untuk search
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGejala();
    // Listener untuk search
    searchController.addListener(filterGejala);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void fetchGejala() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Map<String, dynamic>> data = await ApiService().getGejala();

      setState(() {
        gejalaList = data;
        filteredGejalaList = data; // Awalnya tampilkan semua data
        isLoading = false;
      });
    } catch (e) {
      print("Error mengambil data gejala: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterGejala() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredGejalaList = gejalaList;
      } else {
        filteredGejalaList = gejalaList.where((gejala) {
          String namaGejala = (gejala['nama'] ?? "").toString().toLowerCase();
          return namaGejala.contains(query);
        }).toList();
      }
    });
  }

  void pilihGejala(String gejalaId, String gejalaName) {
    setState(() {
      if (!gejalaTerpilihIds.contains(gejalaId)) {
        gejalaTerpilihIds.add(gejalaId);
        gejalaTerpilihNames.add(gejalaName);
      }
    });
  }

  void hapusGejala(int index) {
    setState(() {
      gejalaTerpilihIds.removeAt(index);
      gejalaTerpilihNames.removeAt(index);
    });
  }

  void clearSearch() {
    searchController.clear();
    setState(() {
      filteredGejalaList = gejalaList;
    });
  }

  void prosesHasilDiagnosa() async {
    // Validasi minimal 2 gejala
    if (gejalaTerpilihIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan pilih minimal 2 gejala untuk melakukan diagnosa'),
          backgroundColor: Color(0xFF9DC08D),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      // Tampilkan indikator loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Panggil API untuk diagnosa
      final hasilDiagnosa = await ApiService().diagnosa(gejalaTerpilihIds);

      // Tutup dialog loading
      Navigator.pop(context);

      // Navigasi ke halaman hasil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilDiagnosaPage(
            hasilDiagnosa: hasilDiagnosa,
            gejalaTerpilih: gejalaTerpilihNames,
          ),
        ),
      );
    } catch (e) {
      // Tutup dialog loading
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Diagnosa Gejala",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      "Penyakit dan Hama",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Center(
                      child: Card(
                        margin: EdgeInsets.all(20),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Pilih gejala yang Anda temukan",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 15),
                              
                              // Search Bar
                              Container(
                                height: 45,
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    hintText: "Cari gejala...",
                                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                                    suffixIcon: searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.clear, color: Colors.grey),
                                            onPressed: clearSearch,
                                          )
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Color(0xFF9DC08D), width: 2),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              
                              // List Gejala
                              SizedBox(
                                height: 180,
                                child: filteredGejalaList.isEmpty
                                    ? Center(
                                        child: Text(
                                          searchController.text.isNotEmpty 
                                              ? "Tidak ada gejala yang ditemukan" 
                                              : "Tidak ada data gejala"
                                        )
                                      )
                                    : ListView.builder(
                                        itemCount: filteredGejalaList.length,
                                        itemBuilder: (context, index) {
                                          String gejalaId = (filteredGejalaList[index]['id'] ?? "").toString();
                                          String namaGejala = (filteredGejalaList[index]['nama'] ?? "Tidak diketahui").toString();
                                          bool isSelected = gejalaTerpilihIds.contains(gejalaId);
                                          
                                          return Container(
                                            margin: EdgeInsets.symmetric(vertical: 2),
                                            child: ListTile(
                                              title: Text(
                                                namaGejala,
                                                style: TextStyle(
                                                  color: isSelected ? Colors.green : Colors.black,
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                ),
                                              ),
                                              trailing: Icon(
                                                isSelected ? Icons.check_circle : Icons.add_circle,
                                                color: isSelected ? Colors.green : Colors.grey,
                                              ),
                                              onTap: isSelected ? null : () => pilihGejala(gejalaId, namaGejala),
                                              tileColor: isSelected ? Colors.green.shade50 : null,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              
                              Divider(color: Colors.grey),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Gejala Terpilih",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: gejalaTerpilihIds.length >= 2 ? Colors.green : Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${gejalaTerpilihIds.length}/min 2",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              SizedBox(
                                height: 100,
                                child: gejalaTerpilihNames.isEmpty
                                  ? Center(child: Text("Belum ada gejala yang dipilih"))
                                  : SingleChildScrollView(
                                      child: Column(
                                        children: List.generate(gejalaTerpilihNames.length, (index) {
                                          return Container(
                                            margin: EdgeInsets.symmetric(vertical: 2),
                                            child: ListTile(
                                              title: Text(
                                                gejalaTerpilihNames[index], 
                                                style: TextStyle(color: Colors.black, fontSize: 14)
                                              ),
                                              trailing: Icon(Icons.delete, color: Colors.red, size: 20),
                                              onTap: () => hapusGejala(index),
                                              dense: true,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                              ),
                            
                              SizedBox(
                                width: double.infinity,
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: gejalaTerpilihIds.length >= 2 ? Colors.green : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: gejalaTerpilihIds.length >= 2 ? prosesHasilDiagnosa : null,
                                  child: Text(
                                    gejalaTerpilihIds.length >= 2 
                                        ? "Lihat Hasil Diagnosa" 
                                        : "Pilih minimal 2 gejala",
                                    style: TextStyle(
                                      color: Colors.white, 
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}