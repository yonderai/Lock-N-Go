import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/payment_screen.dart';

class ParkingCard extends StatelessWidget {
  final Map parking;

final String userName;
final String userEmail;
final String userPhone;
final String vehicleNumber;
final String userId;

const ParkingCard({
  super.key,
  required this.parking,
  required this.userName,
  required this.userEmail,
  required this.userPhone,
  required this.vehicleNumber,
  required this.userId,
});

  Future<void> _openMap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Use .toString() on everything — backend may return int or String ──
    final String imageUrl  = parking["image"]?.toString()        ?? "";
    final String name      = parking["parking_name"]?.toString() ?? "Unknown";
    final String address   = parking["address"]?.toString()      ?? "";
    final String carPrice  = parking["car_price"]?.toString()    ?? "0";
    final String bikePrice = parking["bike_price"]?.toString()   ?? "0";
    final String carSlots  = parking["car_slots"]?.toString()    ?? "0";
    final String bikeSlots = parking["bike_slots"]?.toString()   ?? "0";
    final String mapLink   = parking["map_link"]?.toString()     ?? "";
    final String uniqueId  = parking["unique_id"]?.toString()    ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Image ──
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.local_parking, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Name ──
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // ── Address ──
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // ── Price & slots grid ──
                Row(
                  children: [
                    Expanded(
                      child: _infoTile(
                        Icons.directions_car_outlined,
                        "Car Price",
                        "₹$carPrice/hr",
                      ),
                    ),
                    Expanded(
                      child: _infoTile(
                        Icons.confirmation_number_outlined,
                        "Car Slots",
                        carSlots,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _infoTile(
                        Icons.two_wheeler_outlined,
                        "Bike Price",
                        "₹$bikePrice/hr",
                      ),
                    ),
                    Expanded(
                      child: _infoTile(
                        Icons.confirmation_number_outlined,
                        "Bike Slots",
                        bikeSlots,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Buttons ──
                Row(
                  children: [

                    // Location
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: mapLink.isNotEmpty
                        ? () => _openMap(mapLink)
                        : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF16a34a),
                          side: const BorderSide(color: Color(0xFF16a34a)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.map_outlined, size: 17),
                        label: const Text(
                          "Location",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Book
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: uniqueId.isNotEmpty
                        ? () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  parking: parking,
                                  userName: userName,
                                  userEmail: userEmail,
                                  userPhone: userPhone,
                                  vehicleNumber: vehicleNumber,
                                   userId: userId,
                                ),
                              ),
                            );

                          }
                        : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.bookmark_add_outlined, size: 17),
                        label: const Text(
                          "Book",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  ],
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2563EB)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}