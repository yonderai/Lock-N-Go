import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map parking;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String vehicleNumber;
  final String userId;

  const PaymentScreen({
    super.key,
    required this.parking,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.vehicleNumber,
    required this.userId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String vehicleType = "";

  DateTime? bookingDate;

  TimeOfDay? entryTime;

  TimeOfDay? exitTime;

  double totalAmount = 0;

  String durationText = "";

  void calculatePrice() {
    if (vehicleType.isEmpty ||
        entryTime == null ||
        exitTime == null) {
      return;
    }

    final startMinutes =
        entryTime!.hour * 60 + entryTime!.minute;

    final endMinutes =
        exitTime!.hour * 60 + exitTime!.minute;

    final diffMinutes =
        endMinutes - startMinutes;

    if (diffMinutes <= 0) {
      setState(() {
        totalAmount = 0;
        durationText = "Invalid Time";
      });
      return;
    }

    final hourlyPrice = vehicleType == "Car"
        ? double.tryParse(
              widget.parking["car_price"].toString(),
            ) ??
            0
        : double.tryParse(
              widget.parking["bike_price"].toString(),
            ) ??
            0;

    final amount =
        (diffMinutes / 60) * hourlyPrice;

    final hours = diffMinutes ~/ 60;
    final minutes = diffMinutes % 60;

    setState(() {
      totalAmount = amount;

      if (hours == 0) {
        durationText = "$minutes minutes";
      } else if (minutes == 0) {
        durationText = "$hours hours";
      } else {
        durationText =
            "$hours hours $minutes minutes";
      }
    });
  }

  Future<void> createBooking() async {
    if (vehicleType.isEmpty ||
        bookingDate == null ||
        entryTime == null ||
        exitTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields",
          ),
        ),
      );
      return;
    }

    final result =
        await ApiService.createBooking(
      bookingData: {
        "parking_id":
            widget.parking["unique_id"],
        "parking_name":
            widget.parking["parking_name"],
        "owner_name":
            widget.parking["owner_name"],

        "user_name": widget.userName,
        "user_email": widget.userEmail,
        "user_phone": widget.userPhone,
        "user_id": widget.userId,

        "vehicle_number":
            widget.vehicleNumber,

        "vehicle_type": vehicleType,

        "amount":
            totalAmount.toStringAsFixed(2),

        "booking_date":
            bookingDate!
                .toIso8601String()
                .split("T")[0],

        "entry_time":
            entryTime!.format(context),

        "exit_time":
            exitTime!.format(context),
      },
    );

    if (result["success"] == true) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
            "Payment Successful",
          ),
          content: const Text(
            "Booking Created Successfully",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"] ??
                "Booking Failed",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Card(
              child: ListTile(
                title: Text(
                  widget.parking["parking_name"]
                      .toString(),
                ),
                subtitle: Text(
                  widget.parking["address"]
                      .toString(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              readOnly: true,
              controller:
                  TextEditingController(
                text: widget.userName,
              ),
              decoration:
                  const InputDecoration(
                labelText: "Name",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              readOnly: true,
              controller:
                  TextEditingController(
                text:
                    widget.vehicleNumber,
              ),
              decoration:
                  const InputDecoration(
                labelText:
                    "Vehicle Number",
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: vehicleType.isEmpty
                  ? null
                  : vehicleType,
              items: const [
                DropdownMenuItem(
                  value: "Car",
                  child: Text("Car"),
                ),
                DropdownMenuItem(
                  value: "Bike",
                  child: Text("Bike"),
                ),
              ],
              onChanged: (value) {
                vehicleType = value!;
                calculatePrice();
              },
              decoration:
                  const InputDecoration(
                labelText:
                    "Vehicle Type",
              ),
            ),

            const SizedBox(height: 15),

            ListTile(
              title: Text(
                bookingDate == null
                    ? "Select Date"
                    : bookingDate!
                        .toString()
                        .split(" ")[0],
              ),
              trailing:
                  const Icon(Icons.date_range),
              onTap: () async {
                final date =
                    await showDatePicker(
                  context: context,
                  firstDate:
                      DateTime.now(),
                  lastDate:
                      DateTime(2030),
                  initialDate:
                      DateTime.now(),
                );

                if (date != null) {
                  setState(() {
                    bookingDate = date;
                  });
                }
              },
            ),

            ListTile(
              title: Text(
                entryTime == null
                    ? "Entry Time"
                    : entryTime!
                        .format(context),
              ),
              trailing:
                  const Icon(Icons.access_time),
              onTap: () async {
                final time =
                    await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.now(),
                );

                if (time != null) {
                  setState(() {
                    entryTime = time;
                  });

                  calculatePrice();
                }
              },
            ),

            ListTile(
              title: Text(
                exitTime == null
                    ? "Exit Time"
                    : exitTime!
                        .format(context),
              ),
              trailing:
                  const Icon(Icons.access_time),
              onTap: () async {
                final time =
                    await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.now(),
                );

                if (time != null) {
                  setState(() {
                    exitTime = time;
                  });

                  calculatePrice();
                }
              },
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "₹ ${totalAmount.toStringAsFixed(2)}",
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  Text(
                    durationText,
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: createBooking,
                child: const Text(
                  "Confirm Payment",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}