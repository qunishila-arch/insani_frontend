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

  Future<void> verifikasiCuti(String kdTrs) async {
    try {
      final r = await http.post(Uri.parse(hrdUrl), body: {'fs_kd_trs': kdTrs});
      final j = json.decode(r.body);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(j['message'] ?? 'Selesai')));

      if (j['status'] == true) {
        fetch();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal verifikasi')));
    }
  }

  String t(dynamic v) => v == null || v.toString().isEmpty ? "-" : v.toString();

  String formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.year}";

  Widget boxDate(String tgl) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(tgl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("List Approved Cuti")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDate: tglMulai,
                              );
                              if (d != null) setState(() => tglMulai = d);
                            },
                            child: boxDate(formatDate(tglMulai)),
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
                              if (d != null) setState(() => tglSelesai = d);
                            },
                            child: boxDate(formatDate(tglSelesai)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: filterData,
                            child: const Text("FILTER"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          value: selectedLokasi,
                          items: lokasiList
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) {
                            selectedLokasi = v!;
                            filterData();
                          },
                          decoration: const InputDecoration(
                            labelText: "Filter Lokasi",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredCuti.isEmpty
                      ? const Center(child: Text("Tidak ada cuti"))
                      : ListView.builder(
                          itemCount: filteredCuti.length,
                          itemBuilder: (c, i) {
                            final d = filteredCuti[i];

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
                                    const Text(
                                      "APPROVED",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    const SizedBox(height: 8),
                                    Text("Lokasi : ${t(d['fs_nm_lokasi'])}"),
                                    const SizedBox(height: 12),
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
              ],
            ),
    );
  }
}
