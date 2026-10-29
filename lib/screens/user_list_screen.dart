import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  
  // Latihan 4: Pisahkan daftar semua user dan daftar user yang terfilter
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  
  // Controller untuk input pencarian
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    // Dengarkan perubahan teks pada kolom pencarian
    _searchController.addListener(_filterUsers);
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _apiService.getUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users; // Awalnya isi filteredUsers sama dengan allUsers
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Latihan 4: Fungsi untuk memfilter user berdasarkan nama atau email secara real-time
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final nameLower = user.name.toLowerCase();
        final emailLower = user.email.toLowerCase();
        return nameLower.contains(query) || emailLower.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Jangan lupa hapus controller saat widget dihancurkan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Latihan 4: Tambahkan TextField pencarian pada AppBar
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari nama atau email...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return const Center(child: Text('User tidak ditemukan.'));
    }

    // Menampilkan daftar user yang telah difilter
    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        return UserCard(user: _filteredUsers[index]);
      },
    );
  }
}