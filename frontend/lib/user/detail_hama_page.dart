import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
import 'dart:typed_data';

class DetailHamaPage extends StatefulWidget {
  final Map<String, dynamic> detailHama;
  final int? hamaId;

  const DetailHamaPage({Key? key, required this.detailHama, this.hamaId})
    : super(key: key);

  @override
  _DetailHamaPageState createState() => _DetailHamaPageState();
}

class _DetailHamaPageState extends State<DetailHamaPage> with TickerProviderStateMixin {
  late Future<Map<String, dynamic>> _detailHamaFuture;
  late Map<String, dynamic> _currentDetailHama;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentDetailHama = widget.detailHama;
    
    // Initialize animation
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Jika hamaId tersedia, fetch data terbaru dari API
    if (widget.hamaId != null) {
      _detailHamaFuture = _fetchDetailHama(widget.hamaId!);
    } else {
      // Jika tidak ada ID, gunakan data yang sudah diberikan
      _detailHamaFuture = Future.value(widget.detailHama);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchDetailHama(int id) async {
    try {
      final detailData = await ApiService().getHamaById(id);
      setState(() {
        _currentDetailHama = detailData;
      });
      return detailData;
    } catch (e) {
      print('Error fetching detail hama: $e');
      // Jika gagal fetch, gunakan data yang sudah ada
      return widget.detailHama;
    }
  }

  // Fungsi untuk memvalidasi URL gambar
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    // Periksa apakah URL berakhir dengan ekstensi gambar yang umum
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  // Widget untuk menampilkan gambar dengan penanganan error yang lebih baik
  Widget _buildImageWidget(String? filename) {
    if (filename == null || filename.isEmpty) {
      return _buildPlaceholderImage(
        "Tidak ada gambar tersedia",
        Icons.image_not_supported,
      );
    }

    return FutureBuilder<Uint8List?>(
      future: ApiService().getHamaImageBytesByFilename(filename),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF609966)),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Memuat gambar...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return _buildPlaceholderImage(
            "Gagal memuat gambar",
            Icons.broken_image,
          );
        } else {
          return Hero(
            tag: 'hama_image_${widget.hamaId}',
            child: Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // Widget untuk placeholder gambar
  Widget _buildPlaceholderImage(String message, IconData icon) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF9DC08D),
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          "Detail Hama",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _detailHamaFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF609966)),
                        strokeWidth: 4,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Memuat data hama...",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return _buildDetailContent(_currentDetailHama);
            }

            final detailData = snapshot.data ?? _currentDetailHama;
            return _buildDetailContent(detailData);
          },
        ),
      ),
    );
  }

  Widget _buildDetailContent(Map<String, dynamic> detailData) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            _buildImageWidget(detailData["foto"]),
            SizedBox(height: 24),

            // Nama Hama Card
            _buildInfoCard(
              title: "Nama Hama",
              content: detailData["nama"] ?? "Nama hama tidak tersedia",
              icon: Icons.bug_report,
              color: Color(0xFF9DC08D),
            ),

            // Deskripsi Card
            _buildInfoCard(
              title: "Deskripsi",
              content: detailData["deskripsi"] ?? "Deskripsi tidak tersedia",
              icon: Icons.description,
              color: Color(0xFF9DC08D),
            ),

            // Penanganan Card
            _buildInfoCard(
              title: "Penanganan",
              content: detailData["penanganan"] ?? "Penanganan tidak tersedia",
              icon: Icons.medical_services,
              color: Color(0xFF9DC08D),
            ),

            // Bottom spacing
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}