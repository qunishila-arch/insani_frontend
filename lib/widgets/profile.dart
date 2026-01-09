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

  String namaPegawai = '';
  String lokasi = '';
  String atasan = '';

  final passCtrl = TextEditingController();
  final ulangCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  void dispose() {
    passCtrl.dispose();
    ulangCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchProfile() async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://192.168.43.87/insani/API/profile.php?action=get&kd_peg=${widget.kdPeg}",
        ),
      );

      final jsonRes = json.decode(res.body);

      if (jsonRes['status']) {
        setState(() {
          namaPegawai = jsonRes['data']['nm_peg'];
          lokasi = jsonRes['data']['nm_lokasi'];
          atasan = jsonRes['data']['nm_atasan'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonRes['message'] ?? 'Gagal ambil data')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi error: $e")));
    }
  }

  Future<void> updatePassword() async {
    if (passCtrl.text != ulangCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password tidak sama")));
      return;
    }

    if (passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak boleh kosong")),
      );
      return;
    }

    try {
      final res = await http.post(
        Uri.parse(
          "http://192.168.43.87/insani/API/profile.php?action=update_password",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"kd_peg": widget.kdPeg, "password": passCtrl.text}),
      );

      final jsonRes = json.decode(res.body);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(jsonRes['message'] ?? "Berhasil")));

      if (jsonRes['status'] == true) {
        passCtrl.clear();
        ulangCtrl.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Pegawai")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 10),
            Text(
              namaPegawai,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Kode Pegawai : ${widget.kdPeg}",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 20),
            _readonlyField("Lokasi", lokasi),
            const SizedBox(height: 10),
            _readonlyField("Atasan", atasan),
            const SizedBox(height: 20),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ulangCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Ulangi Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updatePassword,
                child: const Text("SIMPAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
