import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/konstan.dart';

class VerifCutiPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const VerifCutiPage({super.key, required this.data});

  @override
  State<VerifCutiPage> createState() => _VerifCutiPageState();
}

class _VerifCutiPageState extends State<VerifCutiPage> {
  bool loading = false;

  String t(dynamic v) => v == null || v.toString().isEmpty ? "-" : v.toString();

  Future<void> verifikasi() async {
    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/hrd.php"),
        body: {
          "fs_kd_trs": widget.data['fs_kd_trs'].toString(),
        },
      );

      final Map<String, dynamic> json = jsonDecode(res.body);

      final bool sukses = json['status'] == true;

      if (!mounted) return;

      if (sukses) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json['message'] ?? "Cuti berhasil diverifikasi"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json['message'] ?? "Gagal verifikasi cuti")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi Cuti")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(d['fs_nm_peg']),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(
                      icon: Icons.date_range,
                      title: "Tanggal Cuti",
                      value:
                          "${t(d['fd_tgl_mulai'])}  s/d  ${t(d['fd_tgl_akhir'])}",
                    ),

                    const Divider(height: 24),

                    _infoRow(
                      icon: Icons.assignment,
                      title: "Jenis Cuti",
                      value: t(d['fs_nm_jenis_cuti']),
                    ),

                    const Divider(height: 24),

                    _infoRow(
                      icon: Icons.supervisor_account,
                      title: "Atasan yang Menyetujui",
                      value: t(d['fs_nm_atasan']),
                    ),

                    const Divider(height: 24),

                    _infoRow(
                      icon: Icons.notes,
                      title: "Keterangan",
                      value: t(d['fs_keterangan']),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.verified),
                label: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "VERIFIKASI CUTI",
                        style: TextStyle(fontSize: 16),
                      ),
                onPressed: loading ? null : verifikasi,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
