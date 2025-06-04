import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:SIBAYAM/api_services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // State untuk menyimpan data user
  bool isLoading = true;
  Map<String, dynamic>? userData;
  String? errorMessage;
  String? userRole;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _alamatController = TextEditingController();
  final _nomorTeleponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Panggil API untuk mendapatkan data user saat halaman dibuka
    if (userData == null) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();
    _nomorTeleponController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat data pengguna yang login
  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Ambil data user yang sedang login dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      String? token = prefs.getString('token');
      userRole = prefs.getString('role');

      if (email == null || token == null) {
        throw Exception('Sesi login tidak ditemukan, silahkan login kembali');
      }

      // Buat URL untuk endpoint user API
      var url = Uri.parse("https://backend-sistem-pakar-diagnosa-penya.vercel.app/api/users");

      // Kirim permintaan GET dengan token autentikasi
      var response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        // Parse data respons
        List<dynamic> users = jsonDecode(response.body);
        print("Email login: $email");
        print("Data user dari server: $users");

        // Cari user dengan email yang sama dengan yang login
        Map<String, dynamic>? currentUser;
        for (var user in users) {
          if (user['email'].toString().toLowerCase() == email.toLowerCase()) {
            currentUser = Map<String, dynamic>.from(user);
            print("User ditemukan: $currentUser");
            break;
          }
        }

        if (currentUser == null) {
          print("User dengan email $email tidak ditemukan di response.");
          throw Exception('Data pengguna tidak ditemukan');
        }

        setState(() {
          userData = currentUser;
          userRole = currentUser?['role']; // safe access
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token tidak valid atau expired
        await ApiService.logoutUser(); // Logout user
        throw Exception('Sesi habis, silahkan login kembali');
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Gagal memuat data profil: ${e.toString()}";
      });
    }
    return;
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await ApiService.logoutUser();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal logout: ${e.toString()}")));
    }
  }

  void _showUpdateProfileDialog() {
    // Pre-fill form with current user data
    _nameController.text = userData?['name'] ?? '';
    _emailController.text = userData?['email'] ?? '';
    _alamatController.text = userData?['alamat'] ?? '';
    _nomorTeleponController.text = userData?['nomorTelepon'] ?? '';
    _passwordController.text = ''; // Empty for security

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.edit, color: Color(0xFF9DC08D)),
                SizedBox(width: 8),
                Text('Update Profil'),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xFF9DC08D),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF9DC08D)),
                        ),
                      ),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Nama tidak boleh kosong'
                                  : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Color(0xFF9DC08D)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF9DC08D)),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return 'Email tidak boleh kosong';
                        if (!value!.contains('@')) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        helperText:
                            'Kosongkan jika tidak ingin mengubah password',
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF9DC08D)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF9DC08D)),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value?.isNotEmpty ?? false) {
                          if (value!.length < 6)
                            return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(
                        labelText: 'Alamat',
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Color(0xFF9DC08D),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF9DC08D)),
                        ),
                      ),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Alamat tidak boleh kosong'
                                  : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nomorTeleponController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon',
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF9DC08D)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF9DC08D)),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Nomor telepon tidak boleh kosong'
                                  : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.cancel, color: Colors.grey),
                label: Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final apiService = ApiService();
                      await apiService.updateUser(
                        id: userData!['id'],
                        name: _nameController.text,
                        email: _emailController.text,
                        password:
                            _passwordController.text.isEmpty
                                ? null
                                : _passwordController.text,
                        alamat: _alamatController.text,
                        nomorTelepon: _nomorTeleponController.text,
                      );

                      Navigator.pop(context);
                      await _loadUserData(); // Refresh profile data

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Profil berhasil diperbarui'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Gagal memperbarui profil: ${e.toString()}',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: Icon(Icons.save, color: Colors.white),
                label: Text('Update', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9DC08D),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9DC08D),
      body: Stack(
        children: [
          // Background decoration
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF9DC08D), Color(0xFF8BB37A)],
              ),
            ),
          ),

          // Judul halaman dengan icon
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_circle, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        "Profil Pengguna",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Ikon back di pojok kiri atas
          Positioned(
            top: 40.0,
            left: 16.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // Isi halaman
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card box untuk data pengguna
                  Container(
                    width: 450,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child:
                            isLoading
                                ? _buildLoadingState()
                                : errorMessage != null
                                ? _buildErrorState()
                                : _buildUserInfoCard(),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Button untuk update data profil
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showUpdateProfileDialog,
                          icon: Icon(
                            Icons.edit,
                            color: Color(0xFF9DC08D),
                            size: 20,
                          ),
                          label: Text(
                            "Update Profil",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9DC08D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Button untuk logout
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context),
                          icon: Icon(
                            Icons.logout,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          label: Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan loading spinner
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF9DC08D)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, color: Color(0xFF9DC08D)),
              SizedBox(width: 8),
              Text("Memuat data profil..."),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan pesan error
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            errorMessage ?? "Terjadi kesalahan",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadUserData,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text("Coba Lagi", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9DC08D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan informasi user yang berhasil dimuat
  Widget _buildUserInfoCard() {
    if (userData == null) {
      return Center(child: Text("Data pengguna belum dimuat."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header card
        Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF9DC08D), size: 24),
            SizedBox(width: 8),
            Text(
              "Informasi Profil",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9DC08D),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        _buildProfileItem(Icons.person, "Nama", userData?['name'] ?? '-'),
        SizedBox(height: 12),

        _buildProfileItem(Icons.email, "Email", userData?['email'] ?? '-'),
        SizedBox(height: 12),

        _buildProfileItem(
          Icons.location_on,
          "Alamat",
          userData?['alamat'] ?? '-',
        ),
        SizedBox(height: 12),

        _buildProfileItem(
          Icons.admin_panel_settings,
          "Role",
          userData?['role'] ?? '-',
        ),
      ],
    );
  }

  // Fungsi untuk membuat item dalam Card box dengan icon
  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF9DC08D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Color(0xFF9DC08D), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
