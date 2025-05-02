import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api/auth';
  static const String gejalaUrl = 'http://localhost:5000/api/gejala';
  static const String hamaUrl = 'http://localhost:5000/api/hama';
  static const String penyakitUrl = 'http://localhost:5000/api/penyakit';
  static const String rulesPenyakitUrl ='http://localhost:5000/api/rules_penyakit';
  static const String rulesHamaUrl = 'http://localhost:5000/api/rules_hama';

  // Fungsi Login (dengan perbaikan)
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

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Login gagal: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Terjadi kesalahan saat login");
    }
  }

  // Fungsi Logout
  static Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
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
      final response = await http.get(Uri.parse(ApiService.hamaUrl));

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
        throw Exception("Gagal mengambil data hama");
      }
    } catch (e) {
      print("Error getHama: $e");
      throw Exception("Gagal mengambil data hama");
    }
  }

  // Tambah hama baru (kode otomatis)
  Future<Map<String, dynamic>> createHama(
    String nama,
    String deskripsi,
    String penanganan,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(hamaUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama": nama,
          "deskripsi": deskripsi,
          "penanganan": penanganan,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal menambahkan hama');
      }
    } catch (e) {
      print('Error createHama: $e');
      throw Exception('Gagal menambahkan hama');
    }
  }

  // Update hama berdasarkan ID
  Future<Map<String, dynamic>> updateHama(
    int id,
    String nama,
    String deskripsi,
    String penanganan,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$hamaUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama": nama,
          "deskripsi": deskripsi,
          "penanganan": penanganan,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mengupdate hama');
      }
    } catch (e) {
      print('Error updateHama: $e');
      throw Exception('Gagal mengupdate hama');
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

  // Tambah penyakit baru (kode otomatis)
  Future<Map<String, dynamic>> createPenyakit(
    String nama,
    String deskripsi,
    String penanganan,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(penyakitUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama": nama,
          "deskripsi": deskripsi,
          "penanganan": penanganan,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal menambahkan penyakit');
      }
    } catch (e) {
      print('Error createPenyakit: $e');
      throw Exception('Gagal menambahkan penyakit');
    }
  }

  // Update penyakit berdasarkan ID
  Future<Map<String, dynamic>> updatePenyakit(
    int id,
    String nama,
    String deskripsi,
    String penanganan,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$penyakitUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nama": nama,
          "deskripsi": deskripsi,
          "penanganan": penanganan,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal mengupdate penyakit');
      }
    } catch (e) {
      print('Error updatePenyakit: $e');
      throw Exception('Gagal mengupdate penyakit');
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

  // Fungsi untuk lupa password
  Future<void> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': newPassword, // Kirim password baru
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Gagal memperbarui password',
      );
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
    final response = await http.delete(
      Uri.parse('$rulesPenyakitUrl/$id'),
    );
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
    final response = await http.delete(
      Uri.parse('$rulesHamaUrl/$id'),
    );
    return response;
  }
}
