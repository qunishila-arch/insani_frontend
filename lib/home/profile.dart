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

  @override
  void initState() {
    super.initState();
    debugPrint("KD PEG DI PROFILE: ${widget.kdPeg}");
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.43.87/insani/API/profile.php?kd_peg=${widget.kdPeg}",
        ),
      );

      debugPrint("RESPONSE PROFILE: ${response.body}");

      final result = json.decode(response.body);

      if (result['status'] == true) {
        setState(() {
          namaPegawai = result['data']['nm_peg'];
          lokasi = result['data']['nm_lokasi'];
          isLoading = false;
        });
      } else {
        isLoading = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } catch (e) {
      debugPrint("ERROR PROFILE: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Icon(Icons.person_outline),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    namaPegawai,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Kode Pegawai: ${widget.kdPeg}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _ProfileField(
                          label: 'Lokasi',
                          initialValue: lokasi,
                          enabled: false,
                        ),
                        const SizedBox(height: 12),
                        const _ProfileField(
                          label: 'Password Baru',
                          obscure: true,
                        ),
                        const SizedBox(height: 12),
                        const _ProfileField(
                          label: 'Ulangi Password',
                          obscure: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // nanti isi update password
                        },
                        child: const Text('SIMPAN'),
                      ),
                    ),
                  ),

                  const Spacer(),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      '© RSI Wonosobo 2025',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final bool obscure;
  final bool enabled;
  final String? initialValue;

  const _ProfileField({
    required this.label,
    this.obscure = false,
    this.enabled = true,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      enabled: enabled,
      controller: initialValue != null
          ? TextEditingController(text: initialValue)
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
