import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:art_sweetalert/art_sweetalert.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class LoginScreen extends ConsumerWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo (gunakan ikon Unicode + teks)
              const SizedBox(height: 40),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner, // Ikon RFID/absensi
                    color: Color(0xFF3B82F6),
                    size: 48,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'RFID Absensi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Sistem Absensi Siswa',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[400],
                  ),
                ),
                cursorColor: const Color(0xFF3B82F6),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[400],
                  ),
                ),
                cursorColor: const Color(0xFF3B82F6),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // Button Login
              CustomButton(
                text: 'Masuk',
                onPressed: () async {
                  final username = _usernameController.text.trim();
                  final password = _passwordController.text.trim();

                  if (username.isEmpty || password.isEmpty) {
                    ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.danger,
                        title: "Error",
                        text: "Username dan password tidak boleh kosong.",
                      ),
                    );
                    return;
                  }

                  try {
                    // await ref
                    //     .read(authProvider.notifier)
                    //     .login(username, password);
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  } catch (e) {
                    ArtSweetAlert.show(
                      context: context,
                      artDialogArgs: ArtDialogArgs(
                        type: ArtSweetAlertType.danger,
                        title: "Login Gagal",
                        text: e.toString(),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Footer
              Text(
                'Aplikasi Absensi Berbasis RFID • v1.0',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
