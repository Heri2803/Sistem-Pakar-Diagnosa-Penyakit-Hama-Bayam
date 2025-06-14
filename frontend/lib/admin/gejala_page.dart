import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart'; // Pastikan file ini sesuai

class GejalaPage extends StatefulWidget {
  @override
  _GejalaPageState createState() => _GejalaPageState();
}

class _GejalaPageState extends State<GejalaPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> gejalaList = [];
  List<Map<String, dynamic>> filteredGejalaList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    fetchGejala();
    searchController.addListener(_filterGejala);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // 🔹 Ambil data gejala dari API
  Future<void> fetchGejala() async {
    try {
      final data = await apiService.getGejala();
      setState(() {
        gejalaList = data;
        filteredGejalaList = data;
      });
    } catch (e) {
      print('Error fetching gejala: $e');
    }
  }

  void _filterGejala() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredGejalaList = gejalaList.where((gejala) {
        String nama = (gejala['nama'] ?? '').toLowerCase();
        String kode = (gejala['kode'] ?? '').toLowerCase();
        return nama.contains(query) || kode.contains(query);
      }).toList();
      currentPage = 0; // Reset pagination saat search
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (!isSearchVisible) {
        searchController.clear();
        filteredGejalaList = gejalaList;
      }
    });
  }

  // 🔹 Tambah gejala baru ke API
  void _tambahGejala() {
    TextEditingController namaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Gejala Baru'),
          content: TextField(
            controller: namaController,
            decoration: InputDecoration(labelText: 'Nama'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (namaController.text.isNotEmpty) {
                  try {
                    await apiService.createGejala(namaController.text);
                    Navigator.pop(context);
                    fetchGejala(); // Refresh data setelah tambah
                  } catch (e) {
                    print('Error tambah gejala: $e');
                  }
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
  
  void showEditDialog(BuildContext context, Map<String, dynamic> gejala) {
    final TextEditingController editNamaController = TextEditingController(text: gejala['nama'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Gejala'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNamaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiService.updateGejala(
                    gejala['id'],
                    editNamaController.text
                  );
                  fetchGejala();
                  Navigator.pop(context);
                } catch (e) {
                  print("Error updating gejala: $e");
                }
              },
              child: Text('Simpan', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Hapus gejala dari API
  void _hapusGejala(int id) async {
    try {
      await apiService.deleteGejala(id);
      fetchGejala(); // Refresh data setelah hapus
    } catch (e) {
      print('Error hapus gejala: $e');
    }
  }

  void _konfirmasiHapus(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus gejala ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup pop-up tanpa menghapus
              },
              child: Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup pop-up
                _hapusGejala(id); // Lanjutkan proses hapus
              },
              child: Text('Ya, Hapus'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  //pagination
  int currentPage = 0;
  int rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    int start = currentPage * rowsPerPage;
    int end = (start + rowsPerPage < filteredGejalaList.length)
        ? start + rowsPerPage
        : filteredGejalaList.length;
    List currentPageData = filteredGejalaList.sublist(start, end);

    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Gejala'),
        backgroundColor: Color(0xFF9DC08D),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          // Search Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleSearch,
                  icon: Icon(Icons.search),
                  label: Text('Cari'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9DC08D),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Search Field (conditional)
          if (isSearchVisible)
            Container(
              margin: EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau kode gejala...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: _toggleSearch,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Data List
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentPageData.length,
                      itemBuilder: (context, index) {
                        final gejala = currentPageData[index];
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              // Card dengan nama gejala
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () => showEditDialog(context, gejala),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            gejala['nama'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            gejala['kode'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 14,
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
                              // Button hapus di luar card
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => _konfirmasiHapus(gejala['id']),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  // Pagination
                  if (filteredGejalaList.length > rowsPerPage)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left),
                          onPressed: currentPage > 0
                              ? () => setState(() => currentPage--)
                              : null,
                        ),
                        Text(
                          'Halaman ${currentPage + 1}',
                          style: TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right),
                          onPressed: (currentPage + 1) * rowsPerPage < filteredGejalaList.length
                              ? () => setState(() => currentPage++)
                              : null,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahGejala,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF9DC08D),
      ),
    );
  }
}