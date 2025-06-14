import 'package:flutter/material.dart';
import 'package:SIBAYAM/api_services/api_services.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _alamatController = TextEditingController();
  final _nomorTeleponController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();
    _nomorTeleponController.dispose();
    _searchController.dispose();
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

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _alamatController.clear();
      _nomorTeleponController.clear();

      await _loadUsers();

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
      String? newPassword =
          _passwordController.text.isEmpty ? null : _passwordController.text;

      await apiService.updateUser(
        id: user['id'],
        name: _nameController.text,
        email: _emailController.text,
        password: newPassword,
        alamat: _alamatController.text,
        nomorTelepon: _nomorTeleponController.text,
      );

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _alamatController.clear();
      _nomorTeleponController.clear();

      await _loadUsers();

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

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Navigator.pop(context);
                await apiService.deleteUser(user['id']);
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(Map<String, dynamic> user) {
    _nameController.text = user['name'] ?? '';
    _emailController.text = user['email'] ?? '';
    _alamatController.text = user['alamat'] ?? '';
    _nomorTeleponController.text = user['nomorTelepon'] ?? '';
    _passwordController.text = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Nama tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email tidak boleh kosong';
                    if (!value!.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    helperText: 'Kosongkan jika tidak ingin mengubah password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isNotEmpty ?? false) {
                      if (value!.length < 6) return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _alamatController,
                  decoration: InputDecoration(labelText: 'Alamat'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Alamat tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: _nomorTeleponController,
                  decoration: InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Nomor telepon tidak boleh kosong' : null,
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
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _alamatController.clear();
    _nomorTeleponController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
        filteredUsers = userList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = users;
      } else {
        filteredUsers = users.where((user) {
          final name = user['name']?.toString().toLowerCase() ?? '';
          final role = user['role']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          return name.contains(searchQuery) || role.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _navigateToUserDetail(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailPage(
          user: user,
          onUserUpdated: _loadUsers,
          onUserDeleted: _loadUsers,
        ),
      ),
    );
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Container(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterUsers,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama atau role...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF9DC08D)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _filterUsers('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF9DC08D), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                // User List
                Expanded(
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchController.text.isNotEmpty 
                                    ? Icons.search_off 
                                    : Icons.people_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty 
                                    ? 'Tidak ada pengguna yang ditemukan'
                                    : 'Tidak ada pengguna',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              if (_searchController.text.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  'Coba kata kunci lain',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: user['role'] == 'admin'
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.green.withOpacity(0.2),
                                  child: Icon(
                                    user['role'] == 'admin' ? Icons.admin_panel_settings : Icons.person,
                                    color: user['role'] == 'admin' ? Colors.blue : Colors.green,
                                  ),
                                ),
                                title: Text(
                                  user['name'] ?? 'Nama tidak tersedia',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Container(
                                  margin: EdgeInsets.only(top: 4),
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user['role'] == 'admin'
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user['role'] ?? 'user',
                                    style: TextStyle(
                                      color: user['role'] == 'admin' ? Colors.blue : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => _navigateToUserDetail(user),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// Halaman Detail User
class UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUserUpdated;
  final VoidCallback onUserDeleted;

  const UserDetailPage({
    Key? key,
    required this.user,
    required this.onUserUpdated,
    required this.onUserDeleted,
  }) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Navigator.pop(context); // Close dialog
                final apiService = ApiService();
                await apiService.deleteUser(user['id']);
                
                Navigator.pop(context); // Go back to list
                onUserDeleted(); // Refresh list
                
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

  void _showUpdateDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: user['name'] ?? '');
    final _emailController = TextEditingController(text: user['email'] ?? '');
    final _alamatController = TextEditingController(text: user['alamat'] ?? '');
    final _nomorTeleponController = TextEditingController(text: user['nomorTelepon'] ?? '');
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Nama tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email tidak boleh kosong';
                    if (!value!.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    helperText: 'Kosongkan jika tidak ingin mengubah password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isNotEmpty ?? false) {
                      if (value!.length < 6) return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _alamatController,
                  decoration: InputDecoration(labelText: 'Alamat'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Alamat tidak boleh kosong' : null,
                ),
                TextFormField(
                  controller: _nomorTeleponController,
                  decoration: InputDecoration(labelText: 'Nomor Telepon'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Nomor telepon tidak boleh kosong' : null,
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
                  Navigator.pop(context);
                  
                  String? newPassword = _passwordController.text.isEmpty 
                      ? null 
                      : _passwordController.text;

                  final apiService = ApiService();
                  await apiService.updateUser(
                    id: user['id'],
                    name: _nameController.text,
                    email: _emailController.text,
                    password: newPassword,
                    alamat: _alamatController.text,
                    nomorTelepon: _nomorTeleponController.text,
                  );

                  Navigator.pop(context); // Go back to list
                  onUserUpdated(); // Refresh list

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
      appBar: AppBar(
        title: Text('Detail Pengguna'),
        backgroundColor: Color(0xFF9DC08D),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showUpdateDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF9DC08D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: user['role'] == 'admin'
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    child: Icon(
                      user['role'] == 'admin' 
                          ? Icons.admin_panel_settings 
                          : Icons.person,
                      size: 40,
                      color: user['role'] == 'admin' ? Colors.blue : Colors.green,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    user['name'] ?? 'Nama tidak tersedia',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['role'] == 'admin'
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      user['role'] ?? 'user',
                      style: TextStyle(
                        color: user['role'] == 'admin' ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Detail Information
            Text(
              'Informasi Detail',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            
            SizedBox(height: 16),
            
            _buildDetailItem(
              icon: Icons.email,
              title: 'Email',
              value: user['email'] ?? 'Email tidak tersedia',
            ),
            
            _buildDetailItem(
              icon: Icons.location_on,
              title: 'Alamat',
              value: user['alamat'] ?? 'Alamat tidak tersedia',
            ),
            
            _buildDetailItem(
              icon: Icons.phone,
              title: 'Nomor Telepon',
              value: user['nomorTelepon'] ?? 'Nomor telepon tidak tersedia',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(0xFF9DC08D),
            size: 24,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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