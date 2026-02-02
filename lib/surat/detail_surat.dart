import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/konstan.dart';

class DetailSuratPage extends StatelessWidget {
  final Map surat;

  const DetailSuratPage({super.key, required this.surat});

  Future<void> _openPdf(BuildContext context) async {
    final file = surat['nama_file'];

    if (file == null || file.toString().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("File tidak tersedia")));
      return;
    }

    final url = "$baseFileUrl$file";
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal membuka file")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Surat")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surat['judul_surat'] ?? '-',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 18),
                      const SizedBox(width: 8),
                      Text(surat['tgl_surat'] ?? '-'),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.person, size: 18),
                      const SizedBox(width: 8),
                      Text("Dibuat oleh: ${surat['user_input'] ?? '-'}"),
                    ],
                  ),

                  const Divider(height: 30),

                  if (surat['nama_file'] != null &&
                      surat['nama_file'].toString().isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Buka File Surat"),
                        onPressed: () => _openPdf(context),
                      ),
                    )
                  else
                    const Text(
                      "Tidak ada file terlampir",
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
