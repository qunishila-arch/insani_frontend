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

  Widget statusWidget(String? status) {
    switch (status) {
      case 'APPROVED':
        return Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 6),
            Text("Disetujui", style: TextStyle(color: Colors.green)),
          ],
        );
      case 'REJECTED':
        return Row(
          children: const [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 6),
            Text("Ditolak", style: TextStyle(color: Colors.red)),
          ],
        );
      default:
        return Row(
          children: const [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 6),
            Text("Belum Disetujui", style: TextStyle(color: Colors.orange)),
          ],
        );
    }
  }

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
                        const SizedBox(height: 5),
                        statusWidget(d['fs_status']),

                        const SizedBox(height: 6),
                        Text("Jenis : ${t(d['fs_nm_jenis_cuti'])}"),
                        Text(
                          "Tanggal : ${t(d['fd_tgl_mulai'])} - ${t(d['fd_tgl_akhir'])}",
                        ),
                        Text("Keterangan : ${t(d['fs_keterangan'])}"),
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
