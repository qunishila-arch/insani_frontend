import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/konstan.dart';
import 'detail_surat.dart';

class ListSuratPage extends StatefulWidget {
  final String kdPeg;
  const ListSuratPage({super.key, required this.kdPeg});

  @override
  State<ListSuratPage> createState() => _ListSuratPageState();
}

class _ListSuratPageState extends State<ListSuratPage> {
  bool loading = true;
  List dataSurat = [];
  List filteredSurat = [];

  late DateTime tglMulai;
  late DateTime tglSelesai;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    tglSelesai = DateTime(now.year, now.month, now.day);
    tglMulai = tglSelesai.subtract(const Duration(days: 7));

    fetchSurat();
  }

  Future<void> fetchSurat() async {
    try {
      final uri = Uri.parse(listSuratUrl,)
          .replace(queryParameters: {'kdPeg': widget.kdPeg});

      final res = await http.get(uri);
      final jsonRes = jsonDecode(res.body);

      if (jsonRes['status'] == true) {
        dataSurat = jsonRes['data'];
        applyFilter();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void applyFilter() {
    filteredSurat = dataSurat.where((s) {
      if (s['tgl_surat'] == null) return false;

      final raw = s['tgl_surat'].toString();
      final dateOnly = raw.split(' ').first;

      final tgl = DateTime.tryParse(dateOnly);
      if (tgl == null) return false;

      return !(tgl.isBefore(tglMulai) || tgl.isAfter(tglSelesai));
    }).toList();

    setState(() {});
  }

  String formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Surat")),
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
                            lastDate: DateTime.now(),
                            initialDate: tglMulai,
                          );
                          if (d != null) setState(() => tglMulai = d);
                        },
                        child: _dateBox(formatDate(tglMulai)),
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
                            lastDate: DateTime.now(),
                            initialDate: tglSelesai,
                          );
                          if (d != null) setState(() => tglSelesai = d);
                        },
                        child: _dateBox(formatDate(tglSelesai)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: applyFilter,
                        child: const Text("FILTER"),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: filteredSurat.isEmpty
                      ? const Center(child: Text("Tidak ada surat"))
                      : ListView.builder(
                          itemCount: filteredSurat.length,
                          itemBuilder: (context, i) {
                            final s = filteredSurat[i];
                            return Card(
                              margin: const EdgeInsets.all(8),
                              child: ListTile(
                                leading: const Icon(Icons.description),
                                title: Text(s['judul_surat']),
                                subtitle: Text("Tanggal: ${s['tgl_surat']}"),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailSuratPage(surat: s),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _dateBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text),
    );
  }
}
