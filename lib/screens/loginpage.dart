import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/user.dart';
import 'admin_dashboard.dart';
import 'qc_dashboard.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: LoginUI(),
      ),
    );
  }
}

class LoginUI extends StatefulWidget {
  const LoginUI({super.key});

  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 440,
        height: 956,
        color: const Color(0xFFD5EAFC),
        child: Stack(
          children: [
            // Logo
            Positioned(
              left: 120,
              top: 200,
              child: Container(
                width: 200,
                height: 110,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("lib/assets/images/chitalebandhulogo.webp"),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),

            // Login Card
            Positioned(
              left: 10,
              right: 10,
              top: 320,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x3F000000), blurRadius: 11, offset: Offset(2, 2))
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'SECURE LOGIN',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C4175),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: isLoading ? null : _handleLogin,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('LOGIN', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    setState(() => isLoading = true);

    // 🔍 DB CHECK
    final User? user = await DatabaseHelper.instance.login(username, password);

    setState(() => isLoading = false);

    if (user != null) {
      if (user.role == 'ADMIN') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else if (user.role == 'QC') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QCDashboard()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Username or Password"), backgroundColor: Colors.red),
      );
    }
  }
}