import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/konstan.dart';

class ApproveCutiPage extends StatefulWidget {
  final String kdPeg;
  const ApproveCutiPage({super.key, required this.kdPeg});

  @override
  State<ApproveCutiPage> createState() => _ApproveCutiPageState();
}

class _ApproveCutiPageState extends State<ApproveCutiPage> {
  bool loading = true;

  List<Map<String, dynamic>> cuti = [];
  List<Map<String, dynamic>> filteredCuti = [];

  late DateTime tglMulai;
  late DateTime tglSelesai;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    tglMulai = DateTime(now.year, now.month, now.day);
    tglSelesai = DateTime(now.year, now.month, now.day);

    fetch();
  }

  Future<void> fetch() async {
    try {
      final r = await http.get(
        Uri.parse("$cutiUrl?action=list_atasan&kd_peg=${widget.kdPeg}"),
      );

      final j = json.decode(r.body);

      setState(() {
        cuti = List<Map<String, dynamic>>.from(j['data'] ?? []);
        filteredCuti = cuti;
        filterTanggal();
        loading = false;
      });
    } catch (_) {
      setState(() {
        cuti = [];
        filteredCuti = [];
        loading = false;
      });
    }
  }

  void filterTanggal() {
    setState(() {
      filteredCuti = cuti.where((item) {
        final start = DateTime.tryParse(item['fd_tgl_mulai'] ?? '');
        final end = DateTime.tryParse(item['fd_tgl_akhir'] ?? '');
        if (start == null || end == null) return false;

        return !(end.isBefore(tglMulai) || start.isAfter(tglSelesai));
      }).toList();
    });
  }

  Future<void> approve(String id) async {
    await http.post(
      Uri.parse("$cutiUrl?action=approve"),
      body: {"kd_trs": id, "kd_peg": widget.kdPeg},
    );
    fetch();
  }

  Future<void> reject(String id, String alasan) async {
    await http.post(
      Uri.parse("$cutiUrl?action=reject"),
      body: {"kd_trs": id, "kd_peg": widget.kdPeg, "alasan": alasan},
    );
    fetch();
  }

  void showRejectDialog(String kdTrs) {
    final TextEditingController alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tolak Pengajuan Cuti"),
        content: TextField(
          controller: alasanController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Alasan",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (alasanController.text.trim().isEmpty) return;
              reject(kdTrs, alasanController.text.trim());
              Navigator.pop(context);
            },
            child: const Text("TOLAK"),
          ),
        ],
      ),
    );
  }

  String t(dynamic v) => v == null || v.toString().isEmpty ? "-" : v.toString();

  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year}";
  }

  Widget statusWidget(String? status) {
    final s = (status ?? '').toUpperCase();
    switch (s) {
      case 'APPROVED':
        return const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 6),
            Text("Disetujui", style: TextStyle(color: Colors.green)),
          ],
        );
      case 'REJECTED':
        return const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 6),
            Text("Ditolak", style: TextStyle(color: Colors.red)),
          ],
        );
      default:
        return const Row(
          children: [
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
      appBar: AppBar(title: const Text("Persetujuan Cuti")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            initialDate: tglMulai,
                          );
                          if (d != null) {
                            setState(() => tglMulai = d);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(formatDate(tglMulai)),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("sampai"),
                      ),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            initialDate: tglSelesai,
                          );
                          if (d != null) {
                            setState(() => tglSelesai = d);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(formatDate(tglSelesai)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: filterTanggal,
                        child: const Text("FILTER"),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: filteredCuti.isEmpty
                      ? const Center(child: Text("Tidak ada pengajuan"))
                      : ListView.builder(
                          itemCount: filteredCuti.length,
                          itemBuilder: (c, i) {
                            final d = filteredCuti[i];
                            final status = (d['fs_status'] ?? 'PENDING')
                                .toString()
                                .toUpperCase();

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
                                    const SizedBox(height: 6),
                                    statusWidget(status),
                                    const SizedBox(height: 8),
                                    Text("Jenis : ${t(d['fs_nm_jenis_cuti'])}"),
                                    Text(
                                      "Tanggal : ${t(d['fd_tgl_mulai'])} - ${t(d['fd_tgl_akhir'])}",
                                    ),
                                    Text(
                                      "Keterangan : ${t(d['fs_keterangan'])}",
                                    ),
                                    const SizedBox(height: 12),
                                    if (status == 'REJECTED' &&
                                        d['fs_alasan_ditolak'] != null &&
                                        d['fs_alasan_ditolak']
                                            .toString()
                                            .isNotEmpty)
                                      Text(
                                        "Alasan Ditolak: ${t(d['fs_alasan_ditolak'])}",
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    if (status == 'PENDING')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  approve(d['fs_kd_trs']),
                                              child: const Text("APPROVE"),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => showRejectDialog(
                                                d['fs_kd_trs'],
                                              ),
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
                ),
              ],
            ),
    );
  }
}
