import 'package:flutter/material.dart';
import 'package:SIBAYAM/admin/edit_penyakit_page.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
import 'tambah_penyakit_page.dart';
import 'edit_penyakit_page.dart';

class PenyakitPage extends StatefulWidget {
  @override
  _PenyakitPageState createState() => _PenyakitPageState();
}

class _PenyakitPageState extends State<PenyakitPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> penyakitList = [];
  List<Map<String, dynamic>> filteredPenyakitList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchPenyakit();
    searchController.addListener(_filterPenyakit);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPenyakit() async {
    try {
      List<Map<String, dynamic>> data = await apiService.getPenyakit();
      setState(() {
        penyakitList = data;
        filteredPenyakitList = data;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _filterPenyakit() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredPenyakitList = penyakitList.where((penyakit) {
        String nama = (penyakit['nama'] ?? '').toLowerCase();
        String kode = (penyakit['kode'] ?? '').toLowerCase();
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
        filteredPenyakitList = penyakitList;
      }
    });
  }

  // 🔹 Hapus penyakit dari API
  void _hapusPenyakit(int id) async {
    try {
      await apiService.deletePenyakit(id);
      _fetchPenyakit(); // Refresh data setelah hapus
    } catch (e) {
      print('Error hapus penyakit: $e');
    }
  }

  void _konfirmasiHapus(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus penyakit ini?'),
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
                _hapusPenyakit(id); // Lanjutkan proses hapus
              },
              child: Text('Ya, Hapus'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEdit(Map<String, dynamic> penyakit) {
    // Parse nilai_pakar dengan aman
    double nilaiPakar = 0.0;
    if (penyakit['nilai_pakar'] != null) {
      // Coba parse jika string
      if (penyakit['nilai_pakar'] is String) {
        try {
          String nilaiStr = penyakit['nilai_pakar'].toString().trim();
          if (nilaiStr.isNotEmpty) {
            nilaiPakar = double.parse(nilaiStr.replaceAll(',', '.'));
          }
        } catch (e) {
          print("Error parsing nilai_pakar: $e");
        }
      }
      // Langsung gunakan jika sudah double
      else if (penyakit['nilai_pakar'] is double) {
        nilaiPakar = penyakit['nilai_pakar'];
      }
      // Jika int, konversi ke double
      else if (penyakit['nilai_pakar'] is int) {
        nilaiPakar = penyakit['nilai_pakar'].toDouble();
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPenyakitPage(
          idPenyakit: penyakit['id'],
          namaAwal: penyakit['nama'] ?? '',
          deskripsiAwal: penyakit['deskripsi'] ?? '',
          penangananAwal: penyakit['penanganan'] ?? '',
          gambarUrl: penyakit['foto'] ?? '',
          nilai_pakar: nilaiPakar,
          onPenyakitUpdated: _fetchPenyakit,
        ),
      ),
    );
  }

  //pagination
  int currentPage = 0;
  int rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    int start = currentPage * rowsPerPage;
    int end = (start + rowsPerPage < filteredPenyakitList.length)
        ? start + rowsPerPage
        : filteredPenyakitList.length;
    List currentPageData = filteredPenyakitList.sublist(start, end);

    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Penyakit'),
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
                  hintText: 'Cari nama atau kode penyakit...',
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
                        final penyakit = currentPageData[index];
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              // Card dengan nama penyakit
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () => _navigateToEdit(penyakit),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            penyakit['nama'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            penyakit['kode'] ?? '-',
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
                                  onPressed: () => _konfirmasiHapus(penyakit['id']),
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
                  if (filteredPenyakitList.length > rowsPerPage)
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
                          onPressed: (currentPage + 1) * rowsPerPage < filteredPenyakitList.length
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahPenyakitPage(
                onPenyakitAdded: _fetchPenyakit,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF9DC08D),
      ),
    );
  }
}