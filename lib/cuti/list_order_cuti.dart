import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/konstan.dart';

class ListOrderCutiPage extends StatefulWidget {
  final String kdPeg;

  const ListOrderCutiPage({super.key, required this.kdPeg});

  @override
  State<ListOrderCutiPage> createState() => _ListOrderCutiPageState();
}

class _ListOrderCutiPageState extends State<ListOrderCutiPage> {
  bool isLoading = true;

  List<Map<String, dynamic>> listCuti = [];
  List<Map<String, dynamic>> filteredCuti = [];

  late DateTime tglMulai;
  late DateTime tglSelesai;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    tglMulai = DateTime(now.year, now.month, now.day);
    tglSelesai = DateTime(now.year, now.month, now.day);

    fetchCuti();
  }

  Future<void> fetchCuti() async {
    try {
      final response = await http.get(
        Uri.parse("$cutiUrl?action=list&kd_peg=${widget.kdPeg}"),
      );

      final jsonBody = json.decode(response.body);

      if (jsonBody is Map &&
          jsonBody['status'] == true &&
          jsonBody['data'] is List) {
        setState(() {
          listCuti = List<Map<String, dynamic>>.from(jsonBody['data']);
          filteredCuti = listCuti;
          filterTanggal();
          isLoading = false;
        });
      } else {
        setState(() {
          listCuti = [];
          filteredCuti = [];
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        listCuti = [];
        filteredCuti = [];
        isLoading = false;
      });
    }
  }

  void filterTanggal() {
    setState(() {
      filteredCuti = listCuti.where((item) {
        final start = DateTime.tryParse(item['fd_tgl_mulai'] ?? '');
        final end = DateTime.tryParse(item['fd_tgl_akhir'] ?? '');
        if (start == null || end == null) return false;

        return !(end.isBefore(tglMulai) || start.isAfter(tglSelesai));
      }).toList();
    });
  }

  String safe(dynamic value) {
    if (value == null || value.toString().isEmpty) return '-';
    return value.toString();
  }

  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year}";
  }

  String statusText(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Disetujui';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return 'Belum Disetujui';
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Order Cuti")),
      body: isLoading
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
                          padding: const EdgeInsets.all(12),
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
                          padding: const EdgeInsets.all(12),
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
                      ? const Center(child: Text("Tidak ada data"))
                      : ListView.builder(
                          itemCount: filteredCuti.length,
                          itemBuilder: (context, index) {
                            final item = filteredCuti[index];
                            final String status = safe(
                              item['fs_status'],
                            ).toUpperCase();

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(
                                  safe(item['fs_nm_jenis_cuti']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      "Tanggal: ${safe(item['fd_tgl_mulai'])} s/d ${safe(item['fd_tgl_akhir'])}",
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      statusText(status),
                                      style: TextStyle(
                                        color: statusColor(status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (status == 'REJECTED' &&
                                        item['fs_alasan_ditolak'] != null &&
                                        item['fs_alasan_ditolak']
                                            .toString()
                                            .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          "Alasan: ${safe(item['fs_alasan_ditolak'])}",
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
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
