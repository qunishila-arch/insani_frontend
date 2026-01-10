import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'list_order_cuti.dart';
import '../core/konstan.dart';

class OrderCutiPage extends StatefulWidget {
  final String kdPeg;

  const OrderCutiPage({super.key, required this.kdPeg});

  @override
  State<OrderCutiPage> createState() => _OrderCutiPageState();
}

class _OrderCutiPageState extends State<OrderCutiPage> {
  List<Map<String, dynamic>> jenisCutiList = [];
  String? selectedCuti;

  final TextEditingController tglMulaiController = TextEditingController();
  final TextEditingController tglSelesaiController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchJenisCuti();
  }

  @override
  void dispose() {
    tglMulaiController.dispose();
    tglSelesaiController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  Future<void> fetchJenisCuti() async {
    try {
      final response = await http.get(Uri.parse("$cutiUrl?action=jenis_cuti"));

      final result = jsonDecode(response.body);

      if (result['status'] == true) {
        setState(() {
          jenisCutiList = List<Map<String, dynamic>>.from(result['data']);
        });
      }
    } catch (_) {
      _notif("Gagal ambil jenis cuti");
    }
  }

  Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> submitCuti() async {
    if (selectedCuti == null ||
        tglMulaiController.text.isEmpty ||
        tglSelesaiController.text.isEmpty ||
        keteranganController.text.isEmpty) {
      _notif("Lengkapi semua data");
      return;
    }

    setState(() => isLoading = true);

    final body = {
      "kd_peg": widget.kdPeg,
      "kd_jenis_cuti": selectedCuti!,
      "tgl_mulai": tglMulaiController.text,
      "tgl_selesai": tglSelesaiController.text,
      "keterangan": keteranganController.text,
    };

    try {
      final response = await http.post(
        Uri.parse("$cutiUrl?action=submit"),
        body: body,
      );

      if (response.statusCode != 200) {
        setState(() => isLoading = false);
        _notif("Server error ${response.statusCode}");
        return;
      }

      final result = jsonDecode(response.body);
      setState(() => isLoading = false);

      _notif(result['message']);

      if (result['status'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ListOrderCutiPage(kdPeg: widget.kdPeg),
          ),
        );
      }
    } catch (_) {
      setState(() => isLoading = false);
      _notif("Gagal submit cuti");
    }
  }

  void _notif(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Form Pengajuan Cuti"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Data Pengajuan Cuti",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: selectedCuti,
                  decoration: InputDecoration(
                    labelText: "Jenis Cuti",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: jenisCutiList.map((e) {
                    return DropdownMenuItem<String>(
                      value: e['fs_kd_jenis_cuti'].toString(),
                      child: Text(e['fs_nm_jenis_cuti'].toString()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedCuti = value),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: tglMulaiController,
                  readOnly: true,
                  onTap: () => pickDate(tglMulaiController),
                  decoration: InputDecoration(
                    labelText: "Tanggal Mulai",
                    suffixIcon: const Icon(Icons.date_range),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: tglSelesaiController,
                  readOnly: true,
                  onTap: () => pickDate(tglSelesaiController),
                  decoration: InputDecoration(
                    labelText: "Tanggal Selesai",
                    suffixIcon: const Icon(Icons.date_range),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: keteranganController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Keterangan",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitCuti,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "AJUKAN CUTI",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
