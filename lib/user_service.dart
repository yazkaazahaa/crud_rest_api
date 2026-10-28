import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'user_model.dart';

class UserService {
  static const String _baseUrl = 'https://reqres.in/api/users';

  // Jika API key ini tidak diterima, ganti dengan API key dari akun ReqRes.
  static const String _apiKey = 'reqres-free-v1';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-api-key': _apiKey,
        'X-Reqres-Env': 'prod',
      };

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl?page=1'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(_messageFor(response.statusCode, 'memuat data'));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
        throw Exception('Format data dari API tidak sesuai.');
      }

      return (decoded['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList();
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } on TimeoutException {
      throw Exception('Permintaan terlalu lama. Coba lagi.');
    } on FormatException {
      throw Exception('Respons API tidak dapat dibaca.');
    }
  }

  Future<Map<String, dynamic>> createUser(String name, String email) async {
    return _sendUserRequest(
      method: 'POST',
      url: Uri.parse(_baseUrl),
      body: {'name': name, 'email': email, 'job': 'Mahasiswa'},
      expectedStatus: 201,
      action: 'menambahkan user',
    );
  }

  Future<Map<String, dynamic>> updateUser(
    int id,
    String name,
    String email,
  ) async {
    return _sendUserRequest(
      method: 'PUT',
      url: Uri.parse('$_baseUrl/$id'),
      body: {'name': name, 'email': email, 'job': 'Mahasiswa'},
      expectedStatus: 200,
      action: 'mengubah user',
    );
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/$id'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(_messageFor(response.statusCode, 'menghapus user'));
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } on TimeoutException {
      throw Exception('Permintaan terlalu lama. Coba lagi.');
    }
  }

  Future<Map<String, dynamic>> _sendUserRequest({
    required String method,
    required Uri url,
    required Map<String, dynamic> body,
    required int expectedStatus,
    required String action,
  }) async {
    try {
      late http.Response response;

      if (method == 'POST') {
        response = await http
            .post(url, headers: _headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 15));
      } else {
        response = await http
            .put(url, headers: _headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 15));
      }

      if (response.statusCode != expectedStatus) {
        throw Exception(_messageFor(response.statusCode, action));
      }

      if (response.body.trim().isEmpty) return <String, dynamic>{};

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception('Respons API tidak sesuai format.');
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } on TimeoutException {
      throw Exception('Permintaan terlalu lama. Coba lagi.');
    } on FormatException {
      throw Exception('Respons API tidak dapat dibaca.');
    }
  }

  String _messageFor(int status, String action) {
    switch (status) {
      case 401:
      case 403:
        return 'API key ditolak. Periksa API key ReqRes di user_service.dart.';
      case 404:
        return 'Endpoint tidak ditemukan (404). Periksa URL API.';
      case 429:
        return 'Batas permintaan API tercapai. Coba lagi nanti.';
      default:
        return 'Gagal $action (HTTP $status).';
    }
  }
}
