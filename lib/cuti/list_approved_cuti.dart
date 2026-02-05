import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/konstan.dart';
import 'verif_cuti.dart';

class ListApprovedCutiPage extends StatefulWidget {
  final String kdPeg;
  const ListApprovedCutiPage({super.key, required this.kdPeg});

  @override
  State<ListApprovedCutiPage> createState() => _ListApprovedCutiPageState();
}

class _ListApprovedCutiPageState extends State<ListApprovedCutiPage> {
  bool loading = true;

  List<Map<String, dynamic>> cuti = [];
  List<Map<String, dynamic>> filteredCuti = [];

  List<String> lokasiList = [];
  String selectedLokasi = 'SEMUA';

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
      final r = await http.get(Uri.parse("$hrdUrl?action=list_approved"));
      final j = json.decode(r.body);

      cuti = List<Map<String, dynamic>>.from(j['data'] ?? []);

      lokasiList = [
        'SEMUA',
        ...{
          for (var c in cuti)
            if (c['fs_kd_lokasi'] != null) c['fs_kd_lokasi'].toString(),
        },
      ];

      filterData();
      loading = false;
      setState(() {});
    } catch (e) {
      loading = false;
      setState(() {});
    }
  }

  void filterData() {
    filteredCuti = cuti.where((item) {
      final start = DateTime.tryParse(item['fd_tgl_mulai'] ?? '');
      final end = DateTime.tryParse(item['fd_tgl_akhir'] ?? '');
      if (start == null || end == null) return false;

      final filterTanggal =
          !(end.isBefore(tglMulai) || start.isAfter(tglSelesai));

      final filterLokasi = selectedLokasi == 'SEMUA'
          ? true
          : item['fs_kd_lokasi'] == selectedLokasi;

      return filterTanggal && filterLokasi;
    }).toList();

    setState(() {});
  }

  String t(dynamic v) => v == null || v.toString().isEmpty ? "-" : v.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Approved Cuti")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Expanded(
              child: filteredCuti.isEmpty
                  ? const Center(child: Text("Tidak ada cuti"))
                  : ListView.builder(
                      itemCount: filteredCuti.length,
                      itemBuilder: (c, i) {
                        final d = filteredCuti[i];
                        final isVerified =
                            d['fs_status_verifikasi'] == 'VERIFIED';

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

                                Text(
                                  isVerified ? "VERIFIED" : "NOT VERIFIED",
                                  style: TextStyle(
                                    color: isVerified
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Text("Lokasi : ${t(d['fs_nm_lokasi'])}"),

                                const SizedBox(height: 12),

                                if (!isVerified)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.verified),
                                      label: const Text("VERIFIKASI CUTI"),
                                      onPressed: () async {
                                        final res = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                VerifCutiPage(data: d),
                                          ),
                                        );

                                        if (res == true) {
                                          fetch();
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
