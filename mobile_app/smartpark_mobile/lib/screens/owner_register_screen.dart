import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final parkingNameController = TextEditingController();

  final googleMapController = TextEditingController();

  final addressController = TextEditingController();

  final carSlotsController = TextEditingController();

  final carPriceController = TextEditingController();

  final bikeSlotsController = TextEditingController();

  final bikePriceController = TextEditingController();

  List<File> parkingImages = [];
  List<File> parkingDocs = [];
  List<File> govtIds = [];

  bool loading = false;

  Future<void> pickFiles(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();

      setState(() {
        if (type == "images") {
          parkingImages = files;
        } else if (type == "docs") {
          parkingDocs = files;
        } else {
          govtIds = files;
        }
      });
    }
  }

  Future<void> registerOwner() async {
    setState(() {
      loading = true;
    });

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://10.0.2.2:8000/owner-register/"),
      );

      request.fields['name'] = nameController.text;

      request.fields['phone'] = phoneController.text;

      request.fields['email'] = emailController.text;

      request.fields['username'] = usernameController.text;

      request.fields['password'] = passwordController.text;

      request.fields['parking_name'] = parkingNameController.text;

      request.fields['google_map'] = googleMapController.text;

      request.fields['address'] = addressController.text;

      request.fields['number_of_car_slots'] = carSlotsController.text;

      request.fields['price_per_hour_for_cars'] = carPriceController.text;

      request.fields['number_of_bike_slots'] = bikeSlotsController.text;

      request.fields['price_per_hour_for_bikes'] = bikePriceController.text;

      for (var image in parkingImages) {
        request.files.add(
          await http.MultipartFile.fromPath('parking_images', image.path),
        );
      }

      for (var doc in parkingDocs) {
        request.files.add(
          await http.MultipartFile.fromPath('parking_docs', doc.path),
        );
      }

      for (var govt in govtIds) {
        request.files.add(
          await http.MultipartFile.fromPath('govt_id', govt.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 302) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful")),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed (${response.statusCode})")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      loading = false;
    });
  }

  Widget textField(
    TextEditingController controller,
    String hint, {
    bool password = false,
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: password,
        maxLines: lines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget fileButton(String title, String type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => pickFiles(type),
          child: Text(title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Owner Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              textField(nameController, "Full Name"),

              textField(phoneController, "Phone"),

              textField(emailController, "Email"),

              textField(usernameController, "Username"),

              textField(passwordController, "Password", password: true),

              textField(parkingNameController, "Parking Name"),

              textField(googleMapController, "Google Map Link"),

              textField(addressController, "Address", lines: 4),

              textField(carSlotsController, "Number Of Car Slots"),

              textField(carPriceController, "Car Price Per Hour"),

              textField(bikeSlotsController, "Number Of Bike Slots"),

              textField(bikePriceController, "Bike Price Per Hour"),

              fileButton("Select Parking Images", "images"),

              fileButton("Select Parking Documents", "docs"),

              fileButton("Select Govt IDs", "govt"),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            registerOwner();
                          }
                        },
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text("Register Parking"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
