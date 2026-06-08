import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController     = TextEditingController();
  final phoneController    = TextEditingController();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final vehicleController  = TextEditingController();

  bool _loading     = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    vehicleController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name     = nameController.text.trim();
    final phone    = phoneController.text.trim();
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();
    final vehicle  = vehicleController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty ||
        password.isEmpty || vehicle.isEmpty) {
      _showSnack("Please fill in all fields");
      return;
    }

    setState(() => _loading = true);

    final data = await ApiService.register(
      name:     name,
      phone:    phone,
      email:    email,
      password: password,
      vehicle:  vehicle,
    );

    setState(() => _loading = false);

    if (data["success"] == true) {
      if (!mounted) return;
      _showSnack("Registration Successful!");
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            name:         data["name"]         ?? name,
            email:        data["email"]        ?? email,
            phone:        data["phone"]        ?? phone,
            vehicle:      data["vehicle"]      ?? vehicle,
            accountType:  data["account_type"] ?? "User",
            uniqueId: data["unique_id"] ?? "",
            parkingName:  "",
          ),
        ),
      );
    } else {
      _showSnack(data["message"] ?? "Registration failed");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("User Registration"),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            const Text(
              "Create Account",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Fill in the details below to register",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // ── Name ──
            _buildField(
              controller: nameController,
              hint: "Full Name",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            // ── Phone ──
            _buildField(
              controller: phoneController,
              hint: "Phone Number",
              icon: Icons.phone_outlined,
              type: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // ── Email ──
            _buildField(
              controller: emailController,
              hint: "Email",
              icon: Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // ── Password ──
            TextField(
              controller: passwordController,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 16),

            // ── Vehicle ──
            _buildField(
              controller: vehicleController,
              hint: "Vehicle Number (e.g. HR26CZ5586)",
              icon: Icons.directions_car_outlined,
            ),

            const SizedBox(height: 32),

            // ── Submit button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}