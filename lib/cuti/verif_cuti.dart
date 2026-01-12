import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/konstan.dart';

class VerifCutiPage extends StatefulWidget {
  final String kdPeg;
  const VerifCutiPage({super.key, required this.kdPeg});

  @override
  State<VerifCutiPage> createState() => _VerifCutiPageState();
}

class _VerifCutiPageState extends State<VerifCutiPage> {
  bool loading = true;
  List cuti = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    final r = await http.get(
      Uri.parse("$cutiUrl?action=list&kd_peg=${widget.kdPeg}"),
    );
    final j = json.decode(r.body);
    setState(() {
      cuti = j['data'] ?? [];
      loading = false;
    });
  }

  Future<void> approve(String id) async {
    await http.post(
      Uri.parse("$cutiUrl?action=approve"),
      body: {"kd_trs": id, "kd_petugas": widget.kdPeg},
    );
    fetch();
  }

  Future<void> reject(String id) async {
    await http.post(
      Uri.parse("$cutiUrl?action=reject"),
      body: {"kd_trs": id, "kd_petugas": widget.kdPeg, "alasan": "Ditolak"},
    );
    fetch();
  }

  String t(v) => v == null || v.toString().isEmpty ? "-" : v.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi Cuti")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cuti.isEmpty
          ? const Center(child: Text("Tidak ada pengajuan"))
          : ListView.builder(
              itemCount: cuti.length,
              itemBuilder: (c, i) {
                final d = cuti[i];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t(d['fs_nm_peg']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("Jenis : ${t(d['fs_nm_jenis_cuti'])}"),
                        Text(
                          "Tanggal : ${t(d['fd_tgl_mulai'])} - ${t(d['fd_tgl_akhir'])}",
                        ),
                        Text("Alasan : ${t(d['fs_keterangan'])}"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => approve(d['fs_kd_trs']),
                                child: const Text("APPROVE"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => reject(d['fs_kd_trs']),
                                child: const Text("REJECT"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
