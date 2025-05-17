import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:frontend/api_services/api_services.dart';
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
      var url = Uri.parse("http://localhost:5000/api/users");

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
            title: Text('Update Profil'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nama'),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Nama tidak boleh kosong'
                                  : null,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return 'Email tidak boleh kosong';
                        if (!value!.contains('@')) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        helperText:
                            'Kosongkan jika tidak ingin mengubah password',
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
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(labelText: 'Alamat'),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Alamat tidak boleh kosong'
                                  : null,
                    ),
                    TextFormField(
                      controller: _nomorTeleponController,
                      decoration: InputDecoration(labelText: 'Nomor Telepon'),
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
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
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
                          content: Text('Profil berhasil diperbarui'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal memperbarui profil: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9DC08D),
                ),
                child: Text('Update'),
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
          // Judul halaman tetap di luar border (di bagian atas dan center)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                children: [
                  Text(
                    "Profil Pengguna",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
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
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Isi halaman
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Card box untuk data pengguna
                  Container(
                    height: 400,
                    width: 450,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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

                  // Button untuk update data profil
                  ElevatedButton(
                    onPressed: _showUpdateProfileDialog,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Update Data Profil",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF9DC08D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Button untuk logout
                  ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF9DC08D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
          Text("Memuat data profil..."),
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
          TextButton(onPressed: _loadUserData, child: Text("Coba Lagi")),
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
        _buildProfileItem("Nama: ${userData?['name'] ?? '-'}"),
        Divider(color: Colors.black),
        _buildProfileItem("Email: ${userData?['email'] ?? '-'}"),
        Divider(color: Colors.black),
        _buildProfileItem("Alamat: ${userData?['alamat'] ?? '-'}"),
        Divider(color: Colors.black),
        _buildProfileItem("Nomor Telepon: ${userData?['nomorTelepon'] ?? '-'}"),
      ],
    );
  }

  // Fungsi untuk membuat item dalam Card box
  Widget _buildProfileItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}