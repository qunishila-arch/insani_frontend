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
  DateTimeRange? selectedRange;
  List<Map<String, dynamic>> filteredCuti = [];

  @override
  void initState() {
    super.initState();
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

  String safe(dynamic value) {
    if (value == null) return '-';
    return value.toString();
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

  void filterByRange() {
    if (selectedRange == null) return;

    setState(() {
      filteredCuti = listCuti.where((item) {
        final start = DateTime.tryParse(item['fd_tgl_mulai'] ?? '');
        final end = DateTime.tryParse(item['fd_tgl_akhir'] ?? '');
        if (start == null || end == null) return false;

        return !(end.isBefore(selectedRange!.start) ||
            start.isAfter(selectedRange!.end));
      }).toList();
    });
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
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (range != null) {
                              setState(() => selectedRange = range);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              selectedRange == null
                                  ? "[ Pilih Tanggal ]"
                                  : "[ ${selectedRange!.start.toString().substring(0, 10)} ] "
                                        "sampai "
                                        "[ ${selectedRange!.end.toString().substring(0, 10)} ]",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: filterByRange,
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
