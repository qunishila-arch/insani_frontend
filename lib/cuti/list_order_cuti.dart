import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListOrderCutiPage extends StatefulWidget {
  final String kdPeg;

  const ListOrderCutiPage({super.key, required this.kdPeg});

  @override
  State<ListOrderCutiPage> createState() => _ListOrderCutiPageState();
}

class _ListOrderCutiPageState extends State<ListOrderCutiPage> {
  List cutiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCuti();
  }

  // Helper untuk menghindari null
  String safeString(dynamic value, [String fallback = '-']) {
    if (value == null) return fallback;
    return value.toString();
  }

  Future<void> fetchCuti() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.43.87/insani/API/cuti.php?action=jenis_cuti",
        ),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result['status'] == true) {
          setState(() {
            cutiList = result['data'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Gagal mengambil data"),
            ),
          );
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil data cuti")),
      );
      print("Error fetchCuti: $e");
    }
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'APPROVED':
        return Colors.blue;
      case 'VERIFIED':
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pengajuan Cuti Saya"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cutiList.isEmpty
              ? const Center(child: Text("Belum ada pengajuan cuti"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cutiList.length,
                  itemBuilder: (context, index) {
                    final item = cutiList[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama jenis cuti
                            Text(
                              safeString(item['fs_nm_jenis_cuti'], 'Tidak ada nama'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Tanggal cuti
                            Text(
                              "📅 ${safeString(item['fd_tgl_mulai'])} s/d ${safeString(item['fd_tgl_selesai'])}",
                              style: const TextStyle(fontSize: 14),
                            ),

                            const SizedBox(height: 8),

                            // Keterangan
                            Text(
                              "📝 ${safeString(item['fs_keterangan'])}",
                              style: const TextStyle(fontSize: 14),
                            ),

                            const SizedBox(height: 12),

                            // Status
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor(item['fs_status'])
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  safeString(item['fs_status']),
                                  style: TextStyle(
                                    color: statusColor(item['fs_status']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
