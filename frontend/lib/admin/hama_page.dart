import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
import 'tambah_hama_page.dart';
import 'edit_hama_page.dart';

class HamaPage extends StatefulWidget {
  @override
  _HamaPageState createState() => _HamaPageState();
}

class _HamaPageState extends State<HamaPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> hamaList = [];
  List<Map<String, dynamic>> filteredHamaList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchHama();
    searchController.addListener(_filterHama);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHama() async {
    try {
      List<Map<String, dynamic>> data = await apiService.getHama();
      setState(() {
        hamaList = data;
        filteredHamaList = data;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _filterHama() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredHamaList = hamaList.where((hama) {
        String nama = (hama['nama'] ?? '').toLowerCase();
        String kode = (hama['kode'] ?? '').toLowerCase();
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
        filteredHamaList = hamaList;
      }
    });
  }

  // 🔹 Hapus gejala dari API
  void _hapusHama(int id) async {
    try {
      await apiService.deleteHama(id);
      _fetchHama(); // Refresh data setelah hapus
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
          content: Text('Apakah Anda yakin ingin menghapus hama ini?'),
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
                _hapusHama(id); // Lanjutkan proses hapus
              },
              child: Text('Ya, Hapus'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEdit(Map<String, dynamic> hama) {
    // Parse nilai_pakar dengan aman
    double nilaiPakar = 0.0;
    if (hama['nilai_pakar'] != null) {
      // Coba parse jika string
      if (hama['nilai_pakar'] is String) {
        try {
          String nilaiStr = hama['nilai_pakar'].toString().trim();
          if (nilaiStr.isNotEmpty) {
            nilaiPakar = double.parse(nilaiStr.replaceAll(',', '.'));
          }
        } catch (e) {
          print("Error parsing nilai_pakar: $e");
        }
      }
      // Langsung gunakan jika sudah double
      else if (hama['nilai_pakar'] is double) {
        nilaiPakar = hama['nilai_pakar'];
      }
      // Jika int, konversi ke double
      else if (hama['nilai_pakar'] is int) {
        nilaiPakar = hama['nilai_pakar'].toDouble();
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHamaPage(
          idHama: hama['id'],
          namaAwal: hama['nama'] ?? '',
          deskripsiAwal: hama['deskripsi'] ?? '',
          penangananAwal: hama['penanganan'] ?? '',
          gambarUrl: hama['foto'] ?? '',
          nilai_pakar: nilaiPakar,
          onHamaUpdated: _fetchHama,
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Aksi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Hapus Hama'),
                onTap: () {
                  Navigator.pop(context);
                  _konfirmasiHapus(id);
                },
              ),
            ],
          ),
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
    int end = (start + rowsPerPage < filteredHamaList.length)
        ? start + rowsPerPage
        : filteredHamaList.length;
    List currentPageData = filteredHamaList.sublist(start, end);

    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Hama'),
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
                  hintText: 'Cari nama hama...',
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
                        final hama = currentPageData[index];
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              // Card dengan nama hama
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () => _navigateToEdit(hama),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hama['nama'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            hama['kode'] ?? '-',
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
                                  onPressed: () => _konfirmasiHapus(hama['id']),
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
                  if (filteredHamaList.length > rowsPerPage)
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
                          onPressed: (currentPage + 1) * rowsPerPage < filteredHamaList.length
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
              builder: (context) => TambahHamaPage(
                onHamaAdded: _fetchHama,
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