import 'package:flutter/material.dart';
import 'package:flutter_absensi/service/API_config.dart';
import 'package:flutter_absensi/utils/shared_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _attendanceHistory = [];
  bool _isLoading = true;
  final Color _primaryColor = const Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    final token = await SharedStorage.getToken();
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _attendanceHistory = responseData['data'];
          _isLoading = false;
        });
      } else {
        _handleError('Gagal memuat riwayat');
      }
    } catch (e) {
      _handleError('Terjadi kesalahan: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          )),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceHistory.isEmpty
              ? const Center(child: Text('Tidak ada riwayat absensi'))
              : ListView.builder(
                  itemCount: _attendanceHistory.length,
                  itemBuilder: (context, index) {
                    final absen = _attendanceHistory[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(absen['status'].toString().toUpperCase()),
                        subtitle:
                            Text('${absen['latitude']}, ${absen['longitude']}'),
                        trailing: Text(absen['waktu_absen']),
                      ),
                    );
                  },
                ),
    );
  }
}
