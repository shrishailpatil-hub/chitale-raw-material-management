import 'package:flutter/material.dart';
import 'inbound_entry_screen.dart';
import 'shelf_assign_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool inboundPressed = false;
  bool shelfPressed = false;
  bool issuePressed = false;
  bool logoutPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ---------------- TOP BAR ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFF1C4175),
                ),
                child: const Center(
                  child: Text(
                    "Operator Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- WELCOME TEXT ----------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome,\nArun Jadhav",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- QUICK STATS TITLE ----------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Quick Stats",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ---------------- QUICK STATS ROW ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard("12", "Pending GRNs", const Color(0xFFF5B52D)),
                  _statCard("8", "Pending Issues", const Color(0xFFF55F51)),
                ],
              ),

              const SizedBox(height: 30),

              // ---------------- ACTION MENU TITLE ----------------
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Action Menu",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- GRID MENU ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  childAspectRatio: 1.2,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _menuButton(
                      label: "Inbound Entry",
                      iconPath: "lib/assets/images/inbound.webp",
                      pressed: inboundPressed,
                      onPressDown: () => setState(() => inboundPressed = true),
                      onPressUp: () => setState(() => inboundPressed = false),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InboundEntryScreen(),
                          ),
                        );
                      },
                    ),


                    _menuButton(
                      label: "Shelf Assign",
                      iconPath: "lib/assets/images/shelfs.webp",
                      pressed: shelfPressed,
                      onPressDown: () => setState(() => shelfPressed = true),
                      onPressUp: () => setState(() => shelfPressed = false),
                      onTap: () {
                        Navigator.push(

                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShelfAssignScreen(),
                          ),
                        );
                      },
                    ),

                    _menuButton(
                      label: "Issue Material",
                      iconPath: "lib/assets/images/issues.webp",
                      pressed: issuePressed,
                      onPressDown: () => setState(() => issuePressed = true),
                      onPressUp: () => setState(() => issuePressed = false),
                      onTap: () => print("Issue Material"),
                    ),

                    _menuButton(
                      label: "Logout",
                      iconPath: "lib/assets/images/logout.webp",
                      pressed: logoutPressed,
                      onPressDown: () => setState(() => logoutPressed = true),
                      onPressUp: () => setState(() => logoutPressed = false),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- STAT CARD ----------------
  Widget _statCard(String value, String label, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  // ---------------- MENU BUTTON (IMAGE BACKGROUND + BLUR + TEXT) ----------------
  Widget _menuButton({
    required String label,
    required String iconPath,
    required bool pressed,
    required VoidCallback onPressDown,
    required VoidCallback onPressUp,
    required VoidCallback onTap,
  }) {
    return Listener(
      onPointerDown: (_) => onPressDown(),
      onPointerUp: (_) => onPressUp(),
      child: AnimatedScale(
        scale: pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 120),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 6,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [

                  // BACKGROUND IMAGE
                  Positioned.fill(
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // LIGHT BLUR (WHITE TRANSPARENT OVERLAY)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),

                  // TEXT ON TOP
                  Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 3,
                          )
                        ],
                      ),
                    ),
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
