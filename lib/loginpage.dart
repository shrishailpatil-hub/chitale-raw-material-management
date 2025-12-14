import 'package:flutter/material.dart';
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

  bool operatorPressed = false;
  bool rndPressed = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 440,
        height: 956,
        color: const Color(0xFFD5EAFC),
        child: Stack(
          children: [
            // Footer text
            const Positioned(
              left: 73,
              top: 891,
              child: SizedBox(
                width: 294,
                child: Text(
                  '2025 © ChitaleGroups. Designed And Developed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF939393),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            // White card background
            Positioned(
              left: -5,
              top: 234,
              child: Container(
                width: 422,
                height: 572,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 11,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              ),
            ),

            // LOGIN TO YOUR ACCOUNT text
            const Positioned(
              left: 35,
              top: 406,
              child: Text(
                'LOGIN TO YOUR ACCOUNT',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            // Username field
            Positioned(
              left: 20,
              top: 444,
              child: Container(
                width: 371,
                height: 67,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Color(0xFFBBBBBB)),
                ),
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Password field
            Positioned(
              left: 20,
              top: 525,
              child: Container(
                width: 371,
                height: 67,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Color(0xFFBBBBBB)),
                ),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // OPERATOR LOGIN button
            Positioned(
              left: 63,
              top: 643,
              child: Material(
                color: Colors.transparent,
                child: Listener(
                  onPointerDown: (_) => setState(() => operatorPressed = true),
                  onPointerUp: (_) => setState(() => operatorPressed = false),
                  child: AnimatedScale(
                    scale: operatorPressed ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminDashboard()),
                          );
                        },
                      child: Ink(
                        width: 315,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853), // NEW GREEN COLOR
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'OPERATOR LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // QC LOGIN button
            Positioned(
              left: 61,
              top: 717,
              child: Material(
                color: Colors.transparent,
                child: Listener(
                  onPointerDown: (_) => setState(() => rndPressed = true),
                  onPointerUp: (_) => setState(() => rndPressed = false),
                  child: AnimatedScale(
                    scale: rndPressed ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.push(

                          context,
                          MaterialPageRoute(builder: (context) => const QCDashboard(),
                        ),
                        );
                      },
                      child: Ink(
                        width: 315,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFF296FF1), // NEW GREEN COLOR
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'QC LOGIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Logo
            Positioned(
              left: 120,
              top: 272,
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
          ],
        ),
      ),
    );
  }
}
