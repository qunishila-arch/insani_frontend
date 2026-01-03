import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/app_colors.dart';
import 'register_page.dart';
import '../home/hrd_home.dart';
import '../home/tu_home.dart';
import '../home/pegawai_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool isLoading = false;

  final TextEditingController Username = TextEditingController();
  final TextEditingController Password = TextEditingController();

  @override
  void dispose() {
    Username.dispose();
    Password.dispose();
    super.dispose();
  }

  Future<void> loginApi() async {
    if (Username.text.isEmpty || Password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username & Password wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.43.87/insani/API/login.php"),
        body: {
          "username": Username.text.trim(),
          "password": Password.text.trim(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Server error: ${response.statusCode}");
      }

      final result = jsonDecode(response.body);
      print(result);
      if (result['status'] == true) {
        final data = result['data'];

        String role = data['role'].toString().trim();
        print('ROLE = [$role]');

        if (!mounted) return;
        if (role == '1') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PegawaiHome()),
          );
        } else if (role == '2') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HrdHome()),
          );
        } else if (role == '3') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TuHome()),
          );
        } else if (role.toUpperCase() == 'PEGAWAI') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PegawaiHome()),
          );
        } else if (role.toUpperCase() == 'HRD') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HrdHome()),
          );
        } else if (role.toUpperCase() == 'TU') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TuHome()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Role tidak dikenali: $role")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal login: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildTextField(),
                    const SizedBox(height: 15),
                    _buildPasswordField(),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: 140,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : loginApi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum Punya Akun? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
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

  Widget _buildTextField() {
    return TextField(
      controller: Username,
      decoration: InputDecoration(
        labelText: "Username",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: Password,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }
}
