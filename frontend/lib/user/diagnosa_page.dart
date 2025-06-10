import 'package:flutter/material.dart';
import 'hasil_diagnosa_page.dart';
import 'package:SIBAYAM/api_services/api_services.dart';

class DiagnosaPage extends StatefulWidget {
  @override
  _DiagnosaPageState createState() => _DiagnosaPageState();
}

class _DiagnosaPageState extends State<DiagnosaPage> {
  List<Map<String, dynamic>> gejalaList = [];
  List<String> gejalaTerpilihIds = []; // Menyimpan ID gejala
  List<String> gejalaTerpilihNames = []; // Menyimpan nama gejala untuk tampilan
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGejala();
  }

  void fetchGejala() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Map<String, dynamic>> data = await ApiService().getGejala();

      setState(() {
        gejalaList = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error mengambil data gejala: $e");
      setState(() {
        isLoading = false;
      });
    }
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

  void prosesHasilDiagnosa() async {
    // Validasi minimal 3 gejala
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
                              SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: gejalaList.isEmpty
                                    ? Center(child: Text("Tidak ada data gejala"))
                                    : ListView.builder(
                                        itemCount: gejalaList.length,
                                        itemBuilder: (context, index) {
                                          String gejalaId = (gejalaList[index]['id'] ?? "").toString();
                                          String namaGejala = (gejalaList[index]['nama'] ?? "Tidak diketahui").toString();
                                          return ListTile(
                                            title: Text(namaGejala),
                                            trailing: Icon(Icons.add_circle, color: Colors.green),
                                            onTap: () => pilihGejala(gejalaId, namaGejala),
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
                                      color: gejalaTerpilihIds.length >= 3 ? Colors.green : Colors.green,
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
                                          return ListTile(
                                            title: Text(gejalaTerpilihNames[index], style: TextStyle(color: Colors.black)),
                                            trailing: Icon(Icons.delete, color: Colors.red),
                                            onTap: () => hapusGejala(index),
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