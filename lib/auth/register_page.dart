import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/app_colors.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? selectedKaryawan;
  bool _obscurePassword = true;
  bool isLoading = false;
  bool isLoadingKaryawan = true;

  final TextEditingController Username = TextEditingController();
  final TextEditingController Password = TextEditingController();

  List<Map<String, String>> daftarKaryawan = [];

  @override
  void initState() {
    super.initState();
    fetchKaryawan();
  }

  @override
  void dispose() {
    Username.dispose();
    Password.dispose();
    super.dispose();
  }

  Future<void> fetchKaryawan() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.87/insani/API/get_karyawan.php"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          daftarKaryawan = List<Map<String, String>>.from(
            (data['data'] as List).map(
              (item) => {
                "kd_peg": item['kd_peg'].toString(),
                "nama": item['nama'].toString(),
              },
            ),
          );
          isLoadingKaryawan = false;
        });
      } else {
        setState(() => isLoadingKaryawan = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat karyawan: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoadingKaryawan = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  Future<void> registerApi() async {
    if (Username.text.isEmpty ||
        Password.text.isEmpty ||
        selectedKaryawan == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi Data!")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.43.87/insani/API/register.php"),
        body: {
          "fs_kd_peg": daftarKaryawan.firstWhere(
            (k) => k['nama'] == selectedKaryawan,
          )['kd_peg']!,
          "username": Username.text.trim(),
          "password": Password.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));

        if (result['status'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/rsi.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 20,
            child: Image.asset('assets/logorsi.png', height: 75),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 120),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "REGISTER",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildTextField("Username"),
                    const SizedBox(height: 15),
                    _buildPasswordField(),
                    const SizedBox(height: 15),
                    isLoadingKaryawan
                        ? const CircularProgressIndicator()
                        : _buildDropdownField(),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: 140,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : registerApi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "SIGN UP",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Sudah Punya Akun? ",
                          style: TextStyle(fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: Username,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: Password,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nama Karyawan",
          style: TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedKaryawan,
          hint: const Text("Pilih Karyawan"),
          items: daftarKaryawan
              .map(
                (e) =>
                    DropdownMenuItem(value: e['nama'], child: Text(e['nama']!)),
              )
              .toList(),
          onChanged: (v) => setState(() => selectedKaryawan = v),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }
}
