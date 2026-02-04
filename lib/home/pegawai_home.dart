import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/konstan.dart';
import '../cuti/order_cuti.dart';
import '../cuti/list_order_cuti.dart';
import '../widgets/profile.dart';
import '../surat/list_surat.dart';
import '../surat/detail_surat.dart';

class PegawaiHome extends StatefulWidget {
  final String kdPeg;

  const PegawaiHome({super.key, required this.kdPeg});

  @override
  State<PegawaiHome> createState() => _PegawaiHomeState();
}

class _PegawaiHomeState extends State<PegawaiHome> {
  bool loadingPengumuman = true;

  Map<String, dynamic>? pengumuman;

  @override
  void initState() {
    super.initState();
    fetchPengumuman();
  }

  Future<void> fetchPengumuman() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/list_surat.php?role=pegawai&kdPeg=${widget.kdPeg}"),
      );

      final jsonData = jsonDecode(res.body);

      if (jsonData['status'] == true &&
          jsonData['data'] != null &&
          jsonData['data'].isNotEmpty) {
        pengumuman = jsonData['data'][0];
      }
    } catch (e) {
      debugPrint("ERROR FETCH PENGUMUMAN: $e");
    }

    setState(() => loadingPengumuman = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Image.asset('assets/logorsi.png', height: 40),
                  const SizedBox(width: 10),
                  const Expanded(child: SizedBox()),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(kdPeg: widget.kdPeg),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            Image.asset(
              'assets/rsi.jpeg',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () {
                  if (pengumuman == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailSuratPage(surat: pengumuman!),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pengumuman',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (loadingPengumuman)
                        const Text("Memuat pengumuman...")
                      else if (pengumuman == null)
                        const Text("Tidak ada pengumuman")
                      else
                        Text(
                          pengumuman!['judul_surat'],
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _menuButton(
                    icon: Icons.edit_document,
                    title: 'Order Cuti',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderCutiPage(kdPeg: widget.kdPeg),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _menuButton(
                    icon: Icons.list_alt,
                    title: 'List Cuti',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ListOrderCutiPage(kdPeg: widget.kdPeg),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _menuButton(
                    icon: Icons.bookmark_border,
                    title: 'Surat',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListSuratPage(kdPeg: widget.kdPeg),
                        ),
                      );
                    },
                  ),
                ],
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

  static Widget _menuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
