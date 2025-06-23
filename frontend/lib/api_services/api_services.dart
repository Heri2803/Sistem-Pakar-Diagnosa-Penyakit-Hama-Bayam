import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://202.74.74.214:5000/api/auth';
  static const String gejalaUrl = 'http://202.74.74.214:5000/api/gejala';
  static const String hamaUrl = 'http://202.74.74.214:5000/api/hama';
  static const String penyakitUrl = 'http://202.74.74.214:5000/api/penyakit';
  static const String rulesPenyakitUrl ='http://202.74.74.214:5000/api/rules_penyakit';
  static const String rulesHamaUrl = 'http://202.74.74.214:5000/api/rules_hama';
  static const String userUrl = 'http://202.74.74.214:5000/api/users';
  static const String diagnosaUrl = 'http://202.74.74.214:5000/api/diagnosa';
  static const String historiUrl = 'http://202.74.74.214:5000/api/histori';
  static const Duration timeout = Duration(seconds: 15);

/// Fungsi untuk mengirim gejala dan menerima hasil diagnosa
Future<Map<String, dynamic>> diagnosa(List<String> gejalaIds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    List<dynamic> parsedGejala;
    try {
      // Coba konversi ke integer jika bisa
      parsedGejala = gejalaIds.map((id) => int.parse(id)).toList();
    } catch (e) {
      print("Konversi ke integer gagal, gunakan string ID.");
      parsedGejala = gejalaIds;
    }

    final response = await http.post(
      Uri.parse(diagnosaUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'gejala': parsedGejala}),
    ).timeout(timeout);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal melakukan diagnosa: ${response.statusCode} - ${response.body}');
    }
  }

Future<List<Map<String, dynamic>>> getHistoriDiagnosa(String userId) async {
  try {
    // Ambil token dari SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception("Token tidak valid");
    }

    final url = '$historiUrl/user/$userId';
    print("Fetching histori from URL: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('data') && responseData['data'] is List) {
        return List<Map<String, dynamic>>.from(responseData['data']);
      } else {
        throw Exception('Format respons tidak valid.');
      }
    } else {
      throw Exception('Gagal memuat histori: ${response.statusCode}');
    }
  } catch (e) {
    print("Error fetching data: $e");
    throw Exception('Terjadi kesalahan saat mengambil histori: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchHistoriDenganDetail(String userId) async {
  try {
    // Panggil API untuk mendapatkan data histori
    final historiResponse = await getHistoriDiagnosa(userId);
    
    // Tambahkan: Panggil API untuk mendapatkan data user
    final userData = await getUserById(userId);
    final String userName = userData != null ? userData['name'] ?? "User $userId" : "User $userId";

    Future<List<Map<String, dynamic>>> fetchHistoriDenganDetail(String userId) async {
  try {
    // Panggil API untuk mendapatkan data histori
    final historiResponse = await getHistoriDiagnosa(userId);
    
    // Perbaiki cara mendapatkan data user
    final userData = await getUserById(userId);
    // Pastikan data user ada dan nama diambil dengan benar
    final String userName = userData != null && userData['name'] != null 
        ? userData['name'] 
        : "User $userId";
    
    print("User Data received: $userData"); // Debug log
    
    // Proses data histori
    List<Map<String, dynamic>> result = historiResponse.map((histori) {
      final gejala = histori['gejala'] ?? {};
      final penyakit = histori['penyakit'] ?? {};
      final hama = histori['hama'] ?? {};
      
      return {
        "id": histori['id'],
        "userId": histori['userId'],
        "name": userName, // Menggunakan nama yang sudah diambil
        "tanggal_diagnosa": histori['tanggal_diagnosa'],
        "hasil": histori['hasil'],
        "gejala_nama": gejala['nama'] ?? "Tidak diketahui",
        "penyakit_nama": penyakit['nama'],
        "hama_nama": hama['nama'],
      };
    }).toList();

    print("Processed Histori Data with Username: $result"); // Debug log
    return result;
  } catch (e) {
    print("Error fetching histori dengan detail: $e");
    return [];
  }
}

    // Proses data histori
    List<Map<String, dynamic>> result = historiResponse.map((histori) {
      // Tangani properti null dengan default value
      final gejala = histori['gejala'] ?? {};
      final penyakit = histori['penyakit'] ?? {};
      final hama = histori['hama'] ?? {};
      
      return {
        "id": histori['id'],
        "userId": histori['userId'],
        "name": userName, // Tambahkan nama user ke hasil
        "tanggal_diagnosa": histori['tanggal_diagnosa'],
        "hasil": histori['hasil'],
        "gejala_nama": gejala['nama'] ?? "Tidak diketahui",
        "penyakit_nama": penyakit['nama'],
        "hama_nama": hama['nama'],
      };
    }).toList();

    print("Processed Histori Data with Username: $result");
    return result;
  } catch (e) {
    print("Error fetching histori dengan detail: $e");
    return [];
  }
}


  // Tambahkan fungsi getToken
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

// Modifikasi fungsi getAllHistori
Future<List<Map<String, dynamic>>> getAllHistori() async {
  try {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('$historiUrl'), // Gunakan historiUrl bukan baseUrl/histori
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> historiList = responseData['data'];
      
      return historiList.map((histori) => histori as Map<String, dynamic>).toList();
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal mengambil data histori'
      );
    }
  } catch (e) {
    print('Error getting histori: $e');
    throw Exception('Gagal mengambil data histori: $e');
  }
}

// Fungsi Login (dengan session management)
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("Login Response Status: ${response.statusCode}");
      print("Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Simpan data user ke SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        print("User ID dari respons login: ${responseData['userId']}");
        
        await prefs.setString('userId', responseData['userId'].toString());
        await prefs.setString('token', responseData['token']);
        await prefs.setString('role', responseData['role']);
        await prefs.setString('email', email); // Simpan email untuk referensi

        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData,
        };
      } else if (response.statusCode == 403) {
        // Handle akun sedang digunakan di perangkat lain
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': 'device_conflict',
          'message': errorData['message'] ?? 'Akun sedang digunakan di perangkat lain',
        };
      } else if (response.statusCode == 401) {
        // Handle email/password salah
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': 'invalid_credentials',
          'message': errorData['message'] ?? 'Email atau password salah',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': 'unknown',
          'message': errorData['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      print("Login Error: $e");
      return {
        'success': false,
        'error': 'network',
        'message': 'Terjadi kesalahan jaringan saat login',
      };
    }
  }

  // Fungsi Logout (dengan API call ke backend)
  static Future<Map<String, dynamic>> logoutUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String? userId = prefs.getString('userId');

      if (token == null) {
        // Jika tidak ada token, langsung clear local storage
        await _clearLocalStorage();
        return {
          'success': true,
          'message': 'Logout berhasil (no active session)',
        };
      }

      // Panggil API logout
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'userId': userId != null ? int.tryParse(userId) : null,
        }),
      );

      print("Logout Response Status: ${response.statusCode}");
      print("Logout Response Body: ${response.body}");

      // Clear local storage terlepas dari response
      await _clearLocalStorage();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Logout berhasil',
        };
      } else {
        // Tetap anggap berhasil karena local storage sudah dibersihkan
        return {
          'success': true,
          'message': 'Logout berhasil (force logout)',
        };
      }
    } catch (e) {
      print("Logout Error: $e");
      // Tetap clear local storage meski ada error
      await _clearLocalStorage();
      return {
        'success': true,
        'message': 'Logout berhasil (with error cleanup)',
      };
    }
  }

  // Fungsi untuk membersihkan local storage
  static Future<void> _clearLocalStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('userId');
    await prefs.remove('email');
  }

  // Fungsi untuk cek apakah user masih login
  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  // Fungsi untuk mendapatkan user ID
  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Fungsi untuk mendapatkan role
  static Future<String?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Fungsi Force Logout (untuk debugging atau handling device conflict)
  static Future<Map<String, dynamic>> forceLogout(String userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/force-logout"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'userId': int.tryParse(userId)}),
      );

      print("Force Logout Response Status: ${response.statusCode}");
      print("Force Logout Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Force logout gagal',
        };
      }
    } catch (e) {
      print("Force Logout Error: $e");
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat force logout',
      };
    }
  }

  // Fungsi untuk handle session timeout di frontend
  static Future<void> handleSessionTimeout() async {
    await _clearLocalStorage();
    // Tambahkan logic untuk redirect ke login page
    // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }


  // Fungsi Cek Login
  static Future<String?> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role'); // Return role jika login
  }

  // Ambil semua gejala
  Future<List<Map<String, dynamic>>> getGejala() async {
    try {
      final response = await http.get(Uri.parse(gejalaUrl));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Gagal mengambil data gejala');
      }
    } catch (e) {
      print('Error getGejala: $e');
      throw Exception('Gagal mengambil data gejala');
    }
  }

  // Tambah gejala baru (kode otomatis)
  Future<Map<String, dynamic>> createGejala(String nama) async {
    try {
      final response = await http.post(
        Uri.parse(gejalaUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nama": nama}),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal menambahkan gejala');
      }
    } catch (e) {
      print('Error createGejala: $e');
      throw Exception('Gagal menambahkan gejala');
    }
  }

  // Update gejala berdasarkan ID
  Future<Map<String, dynamic>> updateGejala(int id, String nama) async {
    try {
      final response = await http.put(
        Uri.parse('$gejalaUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nama": nama}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mengupdate gejala');
      }
    } catch (e) {
      print('Error updateGejala: $e');
      throw Exception('Gagal mengupdate gejala');
    }
  }

  // Hapus gejala berdasarkan ID
  Future<void> deleteGejala(int id) async {
    try {
      final response = await http.delete(Uri.parse('$gejalaUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus gejala');
      }
    } catch (e) {
      print('Error deleteGejala: $e');
      throw Exception('Gagal menghapus gejala');
    }
  }

  // Ambil semua hama
  Future<List<Map<String, dynamic>>> getHama() async {
    try {
      final response = await http.get(Uri.parse(hamaUrl)).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Pastikan "data" ada dan berupa List
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey("data")) {
          final List<dynamic> data = responseData["data"];

          return List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item)),
          );
        } else {
          throw Exception("Format respons API tidak sesuai");
        }
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        throw Exception("Gagal mengambil data hama (Status: ${response.statusCode})");
      }
    } catch (e) {
      print("Error getHama: $e");
      throw Exception("Gagal mengambil data hama: $e");
    }
  }

  Future<Map<String, dynamic>> getHamaById(int id) async {
    try {
      final response = await http.get(Uri.parse('$hamaUrl/$id'));
      print('Fetching hama with ID $id from $hamaUrl/$id');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Periksa format respons
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey("data")) {
          final data = responseData["data"];
          return Map<String, dynamic>.from(data);
        } else if (responseData is Map<String, dynamic>) {
          // Jika langsung mengembalikan objek tanpa wrapper "data"
          return responseData;
        } else {
          throw Exception("Format respons API tidak sesuai");
        }
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        throw Exception(
          "Gagal mengambil data hama dengan ID $id (Status: ${response.statusCode})",
        );
      }
    } catch (e) {
      print("Error getHamaById: $e");
      throw Exception("Gagal mengambil data hama dengan ID $id: $e");
    }
  }

  // Fungsi untuk mendapatkan URL gambar hama
  String getHamaImageUrl(int id) {
    return '$hamaUrl/$id/image';
  }

  // Fungsi untuk mengecek apakah gambar tersedia
  Future<bool> isHamaImageAvailable(int id) async {
    try {
      final url = Uri.parse(getHamaImageUrl(id));
      print('Checking image availability: $url');
      final response = await http.head(url);
      print('Image availability status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print("Error checking image availability: $e");
      return false;
    }
  }

  // Fungsi untuk mengambil gambar hama sebagai bytes
  Future<Uint8List?> getHamaImageBytes(int id) async {
    try {
      final url = Uri.parse(getHamaImageUrl(id));
      print('Fetching image bytes from: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to get image bytes: ${response.statusCode}');
        print(
          'Response body: ${response.body}',
        ); // Tambahkan ini untuk melihat pesan error
        return null;
      }
    } catch (e) {
      print('Error getting image bytes: $e');
      return null;
    }
  }

  Future<Uint8List?> getHamaImageBytesByFilename(String filename) async {
  try {
    final url = Uri.parse('http://202.74.74.214:5000/image_hama/$filename');
    print('Fetching image from: $url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('Failed to fetch image. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching image by filename: $e');
    return null;
  }
}

  // Tambah hama baru (kode otomatis)
  Future<Map<String, dynamic>> createHama(
    String nama,
    String deskripsi,
    String penanganan,
    XFile? pickedFile,
    double? nilai_pakar
  ) async {
    try {
      var uri = Uri.parse(hamaUrl);
      var request = http.MultipartRequest('POST', uri);

      request.fields['nama'] = nama;
      request.fields['deskripsi'] = deskripsi;
      request.fields['penanganan'] = penanganan;
       request.fields['nilai_pakar'] = nilai_pakar.toString();

      print('Mengirim request ke: $uri');
      print('Dengan fields: ${request.fields}');

      if (pickedFile != null) {
        String mimeType = 'image/jpeg';
        String fileName = pickedFile.name;

        if (fileName.isEmpty) {
          fileName = pickedFile.path.split('/').last;
        }

        if (fileName.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        }

        final bytes = await pickedFile.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'foto', // Sesuaikan dengan field name yang diterima backend
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );

        print('Menambahkan file: $fileName (${bytes.length} bytes)');
      } else {
        print('Tidak ada file yang dilampirkan');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Status response: ${response.statusCode}');
      print('Body response: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        String errorMessage =
            'Gagal menambahkan hama (kode: ${response.statusCode})';
        try {
          var errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          }
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error dalam createHama: $e');
      throw Exception('Gagal menambahkan hama: $e');
    }
  }

  // Update hama berdasarkan ID
  Future<Map<String, dynamic>> updateHama(
    int id,
    String nama,
    String deskripsi,
    String penanganan,
    XFile? pickedFile,
    double nilai_pakar
  ) async {
    try {
      var uri = Uri.parse('$hamaUrl/$id');
      var request = http.MultipartRequest('PUT', uri);

      // Tambahkan fields untuk data teks
      request.fields['nama'] = nama;
      request.fields['deskripsi'] = deskripsi;
      request.fields['penanganan'] = penanganan;
      request.fields['nilai_pakar'] = nilai_pakar.toString();

      // Log untuk debugging
      print('Mengirim request ke: $uri');
      print('Dengan fields: ${request.fields}');

      if (pickedFile != null) {
        // Dapatkan tipe MIME berdasarkan ekstensi file
        String mimeType = 'image/jpeg'; // Default
        String fileName = pickedFile.name;

        if (fileName.isEmpty) {
          fileName = pickedFile.path.split('/').last;
        }

        if (fileName.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        }

        // Baca file sebagai bytes
        final bytes = await pickedFile.readAsBytes();

        // Tambahkan file ke request dengan tipe yang tepat
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto', // Nama field ini harus sama dengan yang diharapkan backend
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );

        print('Menambahkan file: $fileName (${bytes.length} bytes)');
      } else {
        print('Tidak ada file yang dilampirkan');
      }

      // Kirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Debug response
      print('Status response: ${response.statusCode}');
      print('Body response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Coba ambil pesan error dari response body
        String errorMessage =
            'Gagal mengupdate hama (kode: ${response.statusCode})';
        try {
          var errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          }
        } catch (e) {
          // Jika gagal parse JSON, gunakan response body langsung
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error dalam updateHama: $e');
      throw Exception('Gagal mengupdate hama: $e');
    }
  }

  // Hapus hama berdasarkan ID
  Future<void> deleteHama(int id) async {
    try {
      final response = await http.delete(Uri.parse('$hamaUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus hama');
      }
    } catch (e) {
      print('Error deleteHama: $e');
      throw Exception('Gagal menghapus hama');
    }
  }

  // Ambil semua penyakit
  Future<List<Map<String, dynamic>>> getPenyakit() async {
    try {
      final response = await http.get(Uri.parse(ApiService.penyakitUrl));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Pastikan "data" ada dan berupa List
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey("data")) {
          final List<dynamic> data = responseData["data"];

          return List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item)),
          );
        } else {
          throw Exception("Format respons API tidak sesuai");
        }
      } else {
        throw Exception("Gagal mengambil data penyakit");
      }
    } catch (e) {
      print("Error getHama: $e");
      throw Exception("Gagal mengambil data penyakit");
    }
  }

  Future<Map<String, dynamic>> getPenyakitById(int id) async {
    try {
      final response = await http.get(Uri.parse('$penyakitUrl/$id'));
      print('Fetching penyakit with ID $id from $penyakitUrl/$id');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData');

        // Periksa format respons
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey("data")) {
          final data = responseData["data"];
          return Map<String, dynamic>.from(data);
        } else if (responseData is Map<String, dynamic>) {
          // Jika langsung mengembalikan objek tanpa wrapper "data"
          return responseData;
        } else {
          throw Exception("Format respons API tidak sesuai");
        }
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        throw Exception(
          "Gagal mengambil data penyakit dengan ID $id (Status: ${response.statusCode})",
        );
      }
    } catch (e) {
      print("Error getPenyakitById: $e");
      throw Exception("Gagal mengambil data penyakit dengan ID $id: $e");
    }
  }

   // Fungsi untuk mendapatkan URL gambar penyakit
  String getPenyakitImageUrl(int id) {
    return '$penyakitUrl/$id/image';
  }

  // Fungsi untuk mengecek apakah gambar tersedia
  Future<bool> isPenyakitImageAvailable(int id) async {
    try {
      final url = Uri.parse(getHamaImageUrl(id));
      print('Checking image availability: $url');
      final response = await http.head(url);
      print('Image availability status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print("Error checking image availability: $e");
      return false;
    }
  }

  Future<Uint8List?> getPenyakitImageBytes(int id) async {
    try {
      final url = Uri.parse(getPenyakitImageUrl(id));
      print('Fetching image bytes from: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to get image bytes: ${response.statusCode}');
        print(
          'Response body: ${response.body}',
        ); // Tambahkan ini untuk melihat pesan error
        return null;
      }
    } catch (e) {
      print('Error getting image bytes: $e');
      return null;
    }
  }

  Future<Uint8List?> getPenyakitImageBytesByFilename(String filename) async {
  try {
    final url = Uri.parse('http://202.74.74.214:5000/image_penyakit/$filename');
    print('Fetching image from: $url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('Failed to fetch image. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error fetching image by filename: $e');
    return null;
  }
}


  // Tambah penyakit baru (kode otomatis)
  Future<Map<String, dynamic>> createPenyakit(
    String nama,
    String deskripsi,
    String penanganan,
    XFile? pickedFile,
    double? nilai_pakar
  ) async {
    try {
      var uri = Uri.parse(penyakitUrl);
      var request = http.MultipartRequest('POST', uri);

      request.fields['nama'] = nama;
      request.fields['deskripsi'] = deskripsi;
      request.fields['penanganan'] = penanganan;
      request.fields['nilai_pakar'] = nilai_pakar.toString();

      print('Mengirim request ke: $uri');
      print('Dengan fields: ${request.fields}');

      if (pickedFile != null) {
        String mimeType = 'image/jpeg';
        String fileName = pickedFile.name;

        if (fileName.isEmpty) {
          fileName = pickedFile.path.split('/').last;
        }

        if (fileName.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        }

        final bytes = await pickedFile.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes(
            'foto', // Sesuaikan dengan field name yang diterima backend
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );

        print('Menambahkan file: $fileName (${bytes.length} bytes)');
      } else {
        print('Tidak ada file yang dilampirkan');
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Status response: ${response.statusCode}');
      print('Body response: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        String errorMessage =
            'Gagal menambahkan penyakit (kode: ${response.statusCode})';
        try {
          var errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          }
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error dalam createPenyakit: $e');
      throw Exception('Gagal menambahkan penyakit: $e');
    }
  }

  // Update penyakit berdasarkan ID
  Future<Map<String, dynamic>> updatePenyakit(
   int id,
    String nama,
    String deskripsi,
    String penanganan,
    XFile? pickedFile,
    double nilai_pakar
  ) async {
    try {
      var uri = Uri.parse('$penyakitUrl/$id');
      var request = http.MultipartRequest('PUT', uri);

      // Tambahkan fields untuk data teks
      request.fields['nama'] = nama;
      request.fields['deskripsi'] = deskripsi;
      request.fields['penanganan'] = penanganan;
      request.fields['nilai_pakar'] = nilai_pakar.toString();

      // Log untuk debugging
      print('Mengirim request ke: $uri');
      print('Dengan fields: ${request.fields}');

      if (pickedFile != null) {
        // Dapatkan tipe MIME berdasarkan ekstensi file
        String mimeType = 'image/jpeg'; // Default
        String fileName = pickedFile.name;

        if (fileName.isEmpty) {
          fileName = pickedFile.path.split('/').last;
        }

        if (fileName.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        }

        // Baca file sebagai bytes
        final bytes = await pickedFile.readAsBytes();

        // Tambahkan file ke request dengan tipe yang tepat
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto', // Nama field ini harus sama dengan yang diharapkan backend
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );

        print('Menambahkan file: $fileName (${bytes.length} bytes)');
      } else {
        print('Tidak ada file yang dilampirkan');
      }

      // Kirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Debug response
      print('Status response: ${response.statusCode}');
      print('Body response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Coba ambil pesan error dari response body
        String errorMessage =
            'Gagal mengupdate hama (kode: ${response.statusCode})';
        try {
          var errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          }
        } catch (e) {
          // Jika gagal parse JSON, gunakan response body langsung
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error dalam updateHama: $e');
      throw Exception('Gagal mengupdate hama: $e');
    }
  }

  // Hapus penyakit berdasarkan ID
  Future<void> deletePenyakit(int id) async {
    try {
      final response = await http.delete(Uri.parse('$penyakitUrl/$id'));
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus penyakit');
      }
    } catch (e) {
      print('Error deletePenyakit: $e');
      throw Exception('Gagal menghapus penyakit');
    }
  }

  //registrasi
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String alamat,
    required String nomorTelepon,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'), // Endpoint register
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'alamat': alamat,
        'nomorTelepon': nomorTelepon,
        'role': 'user', // role default
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal mendaftar',
      );
    }
  }

// Fungsi untuk mengirim kode verifikasi
  Future<void> sendResetCode({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-reset-code'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          jsonDecode(response.body)['message'] ?? 'Gagal mengirim kode verifikasi',
        );
      }
    } catch (e) {
      print('Error sending reset code: $e');
      throw Exception('Gagal mengirim kode verifikasi: $e');
    }
  }

  // Fungsi untuk reset password dengan kode verifikasi
  Future<void> resetPasswordWithCode({
    required String code,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'code': code,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          jsonDecode(response.body)['message'] ?? 'Gagal reset password',
        );
      }
    } catch (e) {
      print('Error resetting password: $e');
      throw Exception('Gagal reset password: $e');
    }
  }

  Future<bool> verifyResetCode({required String email, required String code}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'resetToken': code,
        }),
      );

      if (response.statusCode == 200) {
        // Jika status code 200, berarti kode valid
        return true;
      } else {
        // Jika status code bukan 200, kode tidak valid
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Kode verifikasi tidak valid';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  //  Create Rule penyakit
  static Future<http.Response> createRulePenyakit({
    required int idGejala,
    int? idPenyakit,
    required double nilaiPakar,
  }) async {
    final response = await http.post(
      Uri.parse('$rulesPenyakitUrl'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_gejala': idGejala,
        'id_penyakit': idPenyakit,
        'nilai_pakar': nilaiPakar,
      }),
    );
    return response;
  }

  //get all rules penyakit
  Future<List<dynamic>> getRulesPenyakit() async {
    final response = await http.get(Uri.parse(rulesPenyakitUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['data'] == null) {
        throw Exception('Data rules kosong');
      }

      return data['data'];
    } else {
      throw Exception('Gagal mengambil data rules: ${response.statusCode}');
    }
  }

  //  Update Rule penyakit
  static Future<http.Response> updateRulePenyakit({
    required int id,
    required int idGejala,
    int? idPenyakit,
    required double nilaiPakar,
  }) async {
    final response = await http.put(
      Uri.parse('$rulesPenyakitUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_gejala': idGejala,
        'id_penyakit': idPenyakit,
        'nilai_pakar': nilaiPakar,
      }),
    );
    return response;
  }

  //  Delete Rule penyakit
  static Future<http.Response> deleteRulePenyakit(int id) async {
    final response = await http.delete(Uri.parse('$rulesPenyakitUrl/$id'));
    return response;
  }

  //  Create Rule Hama
  static Future<http.Response> createRuleHama({
    required int idGejala,
    int? idHama,
    required double nilaiPakar,
  }) async {
    try {
      // Mencetak URL untuk debugging
      print("URL API: $rulesHamaUrl");

      // Kirim request POST ke server
      final response = await http.post(
        Uri.parse('$rulesHamaUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_gejala': idGejala,
          'id_hama': idHama,
          'nilai_pakar': nilaiPakar,
        }),
      );

      // Pengecekan status response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Jika berhasil, kembalikan response
        return response;
      } else {
        // Jika gagal, cetak error dan lempar exception
        print("Gagal: ${response.statusCode} - ${response.body}");
        throw Exception('Gagal menyimpan rule hama. ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      rethrow; // Rethrow exception agar bisa ditangani di tempat lain
    }
  }

  //get all rules hama
  Future<List<dynamic>> getRulesHama() async {
    final response = await http.get(Uri.parse(rulesHamaUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['data'] == null) {
        throw Exception('Data rules kosong');
      }

      return data['data'];
    } else {
      throw Exception('Gagal mengambil data rules: ${response.statusCode}');
    }
  }

  //  Update Rule hama
  static Future<http.Response> updateRuleHama({
    required int id,
    required int idGejala,
    int? idHama,
    required double nilaiPakar,
  }) async {
    final response = await http.put(
      Uri.parse('$rulesHamaUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_gejala': idGejala,
        'id_hama': idHama,
        'nilai_pakar': nilaiPakar,
      }),
    );
    return response;
  }

  //  Delete Rule hama
  static Future<http.Response> deleteRuleHama(int id) async {
    final response = await http.delete(Uri.parse('$rulesHamaUrl/$id'));
    return response;
  }

  //get users
  Future<List<Map<String, dynamic>>> getUsers({String? role}) async {
  try {
    String url = ApiService.userUrl;
    if (role != null) {
      url += '?role=$role';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);

      // Filter berdasarkan role jika perlu
      if (role != null) {
        // Mengambil user dengan role yang sesuai
        final filteredData = responseData.where((user) => user['role'] == role).toList();
        return List<Map<String, dynamic>>.from(filteredData);
      }

      // Jika tidak ada filter role, kembalikan semua data
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      throw Exception("Gagal mengambil data user: ${response.statusCode}");
    }
  } catch (e) {
    print("Error getUsers: $e");
    throw Exception("Gagal mengambil data user");
  }
}

Future<Map<String, dynamic>> updateUser({
  required int id,
  String? name,
  String? email,
  String? alamat,
  String? nomorTelepon,
  String? password,
}) async {
  try {
    final response = await http.put(
      Uri.parse('$userUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (alamat != null) 'alamat': alamat,
        if (nomorTelepon != null) 'nomorTelepon': nomorTelepon,
        if (password != null) 'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['user'];
    } else {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal mengupdate user'
      );
    }
  } catch (e) {
    print('Error updating user: $e');
    throw Exception('Gagal mengupdate user: $e');
  }
}

Future<void> deleteUser(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('$userUrl/$id'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // Successful deletion
      print('User deleted successfully');
    } else {
      // Handle error response
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Gagal menghapus user';
      throw Exception(errorMessage);
    }
  } catch (e) {
    print('Error deleting user: $e');
    throw Exception('Gagal menghapus user: $e');
  }
}

// Tambahkan fungsi untuk mendapatkan data user berdasarkan ID
Future<Map<String, dynamic>?> getUserById(String userId) async {
  try {
    final response = await http.get(
      Uri.parse('$userUrl/$userId'), // Use userUrl instead of baseUrl
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Direct return as backend sends user object
    } else {
      print("Error fetching user data: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Exception in getUserById: $e");
    return null;
  }
}
/// Fungsi untuk menghapus histori berdasarkan userId dan tanggalDiagnosa
  Future<Map<String, dynamic>> deleteHistoriByUserAndDate({
    required String userId,
    required String tanggalDiagnosa,
  }) async {
    final url = Uri.parse('$historiUrl/delete');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'tanggal_diagnosa': tanggalDiagnosa,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonDecode(response.body)['message'],
          'data': jsonDecode(response.body)['data']
        };
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'],
          'error': jsonDecode(response.body)['error'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi',
        'error': e.toString(),
      };
    }
  }


}


