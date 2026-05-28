import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

void main() {
  runApp(const SmartParkApp());
}

class SmartParkApp extends StatelessWidget {
  const SmartParkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartPark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
    TextEditingController();

final TextEditingController passwordController =
    TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "SmartPark",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Login to continue",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

             TextField(

               controller: emailController,

               decoration: InputDecoration(
                 hintText: "Email or Phone Number",

                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(12),
                  ),  
                ),
              ),

              const SizedBox(height: 20),

              TextField(

               controller: passwordController,

               obscureText: true,

               decoration: InputDecoration(
                  hintText: "Password",

                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                 onPressed: () async {

                   final response = await http.post(

                     Uri.parse(
                       "http://127.0.0.1:8000/mobile-login/"
                      ),

                     headers: {

                        "Content-Type": "application/json"

                      },

                     body: jsonEncode({

                        "email": emailController.text,

                        "password": passwordController.text

                      }),

                    );

                   final data = jsonDecode(response.body);

                   if (data["success"] == true) {

                     Navigator.push(

                       context,

                       MaterialPageRoute(

                          builder: (context) => DashboardPage(
                              name: data["name"],
                             ),

                            ),

                          );

                        }
                        else {

                          ScaffoldMessenger.of(context).showSnackBar(

                           SnackBar(
                             content: Text(data["message"]),
                            ),

                          );

                        }

                   print(data);

                  },

                 child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text("OR"),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: OutlinedButton(
                  onPressed: () {},

                  child: const Text(
                    "Continue with Google",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text("Don't have an account?"),

                  TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );

                    },

                    child: const Text(
                      "User Registration",
                    ),
                  )

                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();

}

class _RegisterPageState extends State<RegisterPage> {

  final nameController = TextEditingController();

  final phoneController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final vehicleController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("User Registration"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(25),

        child: Column(

          children: [

            TextField(

  controller: nameController,

  decoration: InputDecoration(
    hintText: "Full Name",

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

            const SizedBox(height: 20),

            TextField(

  controller: phoneController,

  decoration: InputDecoration(
    hintText: "Phone Number",

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

            const SizedBox(height: 20),

            TextField(

  controller: emailController,

  decoration: InputDecoration(
    hintText: "Email",

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

            const SizedBox(height: 20),

            TextField(

  controller: passwordController,

  obscureText: true,

  decoration: InputDecoration(
    hintText: "Password",

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

            const SizedBox(height: 20),

            TextField(

  controller: vehicleController,

  decoration: InputDecoration(
    hintText: "Vehicle Number",

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(

  onPressed: () async {

    final response = await http.post(

      Uri.parse(
        "http://127.0.0.1:8000/mobile-register/",
      ),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "name": nameController.text,

        "phone": phoneController.text,

        "email": emailController.text,

        "password": passwordController.text,

        "vehicle": vehicleController.text,

      }),

    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Registration Successful"),
        ),

      );

      Navigator.pushReplacement(

  context,

  MaterialPageRoute(

    builder: (context) => DashboardPage(
      name: nameController.text,
    ),

  ),

);

    }
    else {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(data["message"]),
        ),

      );

    }

  },

  child: const Text(

    "Create Account",

    style: TextStyle(
      fontSize: 18,
    ),

  ),

),
            )

          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {

  final String name;

  const DashboardPage({

    super.key,
    required this.name,

  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();

}

class _DashboardPageState extends State<DashboardPage> {

  List parkings = [];

  @override
  void initState() {

    super.initState();

    loadParkings();

  }

  Future loadParkings() async {

    final response = await http.get(

      Uri.parse(
        "http://127.0.0.1:8000/mobile-parkings/",
      ),

    );

    final data = jsonDecode(response.body);

    setState(() {

      parkings = data["parkings"];

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("SmartPark"),

        backgroundColor: Colors.blue,

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(15),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              "Welcome ${widget.name}",

              style: const TextStyle(

                fontSize: 28,
                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 20),

            ListView.builder(

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              itemCount: parkings.length,

              itemBuilder: (context, index) {

                final parking = parkings[index];

                return Container(

                  margin: const EdgeInsets.only(bottom: 20),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.grey.shade300,

                        blurRadius: 8,

                      )

                    ],

                  ),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      ClipRRect(

                        borderRadius: const BorderRadius.only(

                          topLeft: Radius.circular(20),

                          topRight: Radius.circular(20),

                        ),

                        child: Image.network(

                          parking["image"],

                          height: 220,

                          width: double.infinity,

                          fit: BoxFit.cover,

                        ),

                      ),

                      Padding(

                        padding: const EdgeInsets.all(15),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(

                              parking["parking_name"],

                              style: const TextStyle(

                                fontSize: 24,
                                fontWeight: FontWeight.bold,

                              ),

                            ),

                            const SizedBox(height: 10),

                            Text(

                              "₹ ${parking["price"]} / hour",

                              style: const TextStyle(

                                fontSize: 20,
                                color: Colors.green,

                              ),

                            ),

                            const SizedBox(height: 20),

                            Row(

                              children: [

                                Expanded(

                                  child: ElevatedButton.icon(

                                    onPressed: () async {

                                      final Uri url = Uri.parse(

                                        parking["map_link"],

                                      );

                                      await launchUrl(url);

                                    },

                                    icon: const Icon(Icons.map),

                                    label: const Text("Map"),

                                  ),

                                ),

                                const SizedBox(width: 15),

                                Expanded(

                                  child: ElevatedButton.icon(

                                    onPressed: () {

                                      ScaffoldMessenger.of(context).showSnackBar(

                                        const SnackBar(

                                          content: Text(

                                            "Opening Payment Page",

                                          ),

                                        ),

                                      );

                                    },

                                    icon: const Icon(Icons.payment),

                                    label: const Text("Book"),

                                  ),

                                ),

                              ],

                            )

                          ],

                        ),

                      )

                    ],

                  ),

                );

              },

            )

          ],

        ),

      ),

    );

  }

}