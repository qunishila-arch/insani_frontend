import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String kdPeg;
  const ProfilePage({super.key, required this.kdPeg});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;

  String namaPeg = '';
  String namaAtasan = '';
  String lokasi = '';

  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final url =
        "http://localhost/insani/API/profile.php?kd_peg=${widget.kdPeg}";

    final res = await http.get(Uri.parse(url));
    final jsonData = json.decode(res.body);

    if (jsonData['status'] == true) {
      setState(() {
        namaPeg = jsonData['data']['fs_nm_peg'];
        namaAtasan = jsonData['data']['nm_atasan'] ?? '-';
        lokasi = jsonData['data']['fs_nm_lokasi'];
        isLoading = false;
      });
    }
  }

  Future<void> updatePassword() async {
    if (passwordController.text.isEmpty) return;

    final res = await http.post(
      Uri.parse("http://localhost/insani/API/profile.php"),
      body: {"kd_peg": widget.kdPeg, "password": passwordController.text},
    );

    final jsonData = json.decode(res.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(jsonData['message'])));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(namaPeg, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Atasan: $namaAtasan"),
            Text("Lokasi: $lokasi"),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: updatePassword,
              child: const Text("SIMPAN"),
            ),
          ],
        ),
      ),
    );
  }
}
