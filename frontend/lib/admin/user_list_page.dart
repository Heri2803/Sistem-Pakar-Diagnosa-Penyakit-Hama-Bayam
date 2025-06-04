import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _alamatController = TextEditingController();
  final _nomorTeleponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    // Dispose controllers in dispose method
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();
    _nomorTeleponController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    try {
      await apiService.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        alamat: _alamatController.text,
        nomorTelepon: _nomorTeleponController.text,
      );

      // Clear form
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _alamatController.clear();
      _nomorTeleponController.clear();

      // Refresh user list
      await _loadUsers();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateUser(Map<String, dynamic> user) async {
    try {
      // Hanya kirim password jika diisi
      String? newPassword =
          _passwordController.text.isEmpty ? null : _passwordController.text;

      await apiService.updateUser(
        id: user['id'],
        name: _nameController.text,
        email: _emailController.text,
        password: newPassword, // Kirim null jika password kosong
        alamat: _alamatController.text,
        nomorTelepon: _nomorTeleponController.text,
      );

      // Clear form
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _alamatController.clear();
      _nomorTeleponController.clear();

      // Refresh user list
      await _loadUsers();

      // Show success message with password info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newPassword != null
                ? 'User berhasil diperbarui termasuk password'
                : 'User berhasil diperbarui',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      await apiService.deleteUser(userId);
      await _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Konfirmasi Hapus'),
            content: Text(
              'Apakah Anda yakin ingin menghapus user ${user['name']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    Navigator.pop(context); // Close dialog first
                    await apiService.deleteUser(user['id']);
                    await _loadUsers(); // Refresh the list

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('User berhasil dihapus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus user: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Hapus'),
              ),
            ],
          ),
    );
  }

  void _showUpdateDialog(Map<String, dynamic> user) {
    // Pre-fill form with existing user data
    _nameController.text = user['name'] ?? '';
    _emailController.text = user['email'] ?? '';
    _alamatController.text = user['alamat'] ?? '';
    _nomorTeleponController.text = user['nomorTelepon'] ?? '';
    _passwordController.text = ''; // Empty for security

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Update User'),
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    _updateUser(user);
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

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Tambah User Baru'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nama'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(labelText: 'Alamat'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _nomorTeleponController,
                      decoration: InputDecoration(labelText: 'Nomor Telepon'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        return null;
                      },
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    _addUser();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9DC08D),
                ),
                child: Text('Simpan'),
              ),
            ],
          ),
    );
  }

  Future<void> _loadUsers() async {
    try {
      final userList = await apiService.getUsers();
      setState(() {
        users = userList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengguna'),
        backgroundColor: Color(0xFF9DC08D),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: Color(0xFF9DC08D),
        child: Icon(Icons.add),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    columns: [
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Alamat')),
                      DataColumn(label: Text('No. Telepon')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows:
                        users.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(Text(user['name'] ?? '-')),
                              DataCell(Text(user['email'] ?? '-')),
                              DataCell(Text(user['alamat'] ?? '-')),
                              DataCell(Text(user['nomorTelepon'] ?? '-')),
                              DataCell(
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        user['role'] == 'admin'
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user['role'] ?? 'user',
                                    style: TextStyle(
                                      color:
                                          user['role'] == 'admin'
                                              ? Colors.blue
                                              : Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _showUpdateDialog(user),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _showDeleteConfirmation(user),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
    );
  }
}
