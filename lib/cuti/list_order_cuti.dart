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
  bool isLoading = true;
  List<Map<String, dynamic>> listCuti = [];

  @override
  void initState() {
    super.initState();
    fetchCuti();
  }

  Future<void> fetchCuti() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.43.87/insani/API/cuti.php?action=list&kd_peg=${widget.kdPeg}",
        ),
      );

      final jsonBody = json.decode(response.body);

      if (jsonBody is Map &&
          jsonBody['status'] == true &&
          jsonBody['data'] is List) {
        setState(() {
          listCuti = List<Map<String, dynamic>>.from(jsonBody['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          listCuti = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        listCuti = [];
        isLoading = false;
      });
    }
  }

  /// 🔒 FORCE STRING (ANTI NULL)
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
      case 'PENDING':
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
      case 'PENDING':
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
          : listCuti.isEmpty
          ? const Center(child: Text("Belum ada pengajuan cuti"))
          : ListView.builder(
              itemCount: listCuti.length,
              itemBuilder: (context, index) {
                final item = listCuti[index];

                final String status = safe(item['fs_status']).toUpperCase();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      safe(item['fs_nm_jenis_cuti']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
