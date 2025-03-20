import 'package:flutter/material.dart';
import 'hasil_diagnosa_page.dart';
import 'package:frontend/api_services/api_services.dart';  // Import API service untuk ambil data

class DiagnosaPage extends StatefulWidget {
  @override
  _DiagnosaPageState createState() => _DiagnosaPageState();
}

class _DiagnosaPageState extends State<DiagnosaPage> {
  List<Map<String, dynamic>> gejalaList = [];
  List<String> gejalaTerpilih = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGejala(); // Ambil data dari MySQL saat halaman dibuka
  }

  void fetchGejala() async {
  try {
    setState(() {
      isLoading = true; // Tampilkan loading sebelum data diambil
    });

    List<Map<String, dynamic>> data = await ApiService().getGejala();

    setState(() {
      gejalaList = data; // Simpan data ke dalam state
      isLoading = false; // Matikan loading setelah data berhasil diambil
    });
  } catch (e) {
    print("Error mengambil data gejala: $e");
    setState(() {
      isLoading = false; // Pastikan loading berhenti meskipun terjadi error
    });
  }
}


  void pilihGejala(String gejala) {
    setState(() {
      if (!gejalaTerpilih.contains(gejala)) {
        gejalaTerpilih.add(gejala);
      }
    });
  }

  void hapusGejala(String gejala) {
    setState(() {
      gejalaTerpilih.remove(gejala);
    });
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
                ? Center(child: CircularProgressIndicator()) // Tampilkan loading saat mengambil data
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
                              height: 200, // Perbaiki ukuran list
                              child: gejalaList.isEmpty
                                  ? Center(child: Text("Tidak ada data gejala"))
                                  : ListView.builder(
                                      itemCount: gejalaList.length,
                                      itemBuilder: (context, index) {
                                        String namaGejala = (gejalaList[index]['nama'] ?? "Tidak diketahui").toString();
                                        return ListTile(
                                          title: Text(namaGejala),
                                          trailing: Icon(Icons.add_circle, color: Colors.green),
                                          onTap: () => pilihGejala(namaGejala),
                                        );
                                      },
                                    ),
                            ),
                            Divider(color: Colors.grey),
                            SizedBox(
                              height: 100,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: gejalaTerpilih.map((item) {
                                    return ListTile(
                                      title: Text(item, style: TextStyle(color: Colors.black)),
                                      trailing: Icon(Icons.delete, color: Colors.red),
                                      onTap: () => hapusGejala(item),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HasilDiagnosaPage(gejalaTerpilih: gejalaTerpilih),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Lihat Hasil Diagnosa",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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