import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  String? _savedToken;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  // Memeriksa status token saat halaman dibuka (Latihan 1)
  Future<void> _checkToken() async {
    final hasToken = await _storageService.hasToken();
    final token = await _storageService.getToken();
    
    setState(() {
      _hasToken = hasToken;
      _savedToken = token;
    });
  }

  // Fungsi Konfirmasi dan Proses Logout (Latihan 2)
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Batal
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // a) Hapus token dari secure storage[span_6](start_span)[span_6](end_span)
                await _storageService.deleteToken();

                if (!mounted) return;
                // Tutup dialog
                Navigator.pop(context);

                // c) Kembali ke halaman login[span_7](start_span)[span_7](end_span)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Ya, Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          // Tombol Logout di AppBar (Latihan 2)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selamat Datang di Halaman Utama!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // d) Menampilkan status login / token di HomeScreen[span_8](start_span)[span_8](end_span)
              Text(
                _hasToken ? 'Status: Login Aktif' : 'Status: Tidak ada token',
                style: TextStyle(
                  color: _hasToken ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Token tersimpan:\n${_savedToken ?? "Belum ada token"}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}