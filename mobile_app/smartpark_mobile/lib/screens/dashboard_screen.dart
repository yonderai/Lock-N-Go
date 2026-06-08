import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/parking_card.dart';
import 'user_records_screen.dart';
import 'owner_records_screen.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class DashboardPage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String vehicle;
  final String accountType;
  final String parkingName;
  final String uniqueId;

  const DashboardPage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicle,
    required this.accountType,
    this.parkingName = "",
    required this.uniqueId,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List _parkings         = [];
  List _filteredParkings = [];
  bool _loadingParkings  = true;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadParkings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParkings() async {
    final data = await ApiService.getParkings();
    setState(() {
      _parkings         = data;
      _filteredParkings = data;
      _loadingParkings  = false;
    });
  }

  bool get _isOwner => widget.accountType == "Owner";

  // Initials from name
  String get _initials {
    final parts = widget.name.trim().split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return widget.name.isNotEmpty ? widget.name[0].toUpperCase() : "U";
  }

  void _logout() {

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginPage(),
    ),
    (route) => false,
  );

}

  void _onSearch(String value) {
    setState(() {
      _filteredParkings = _parkings.where((p) {
        return p["parking_name"]
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }
  void _showCompareBottomSheet() {

  Map<String, dynamic>? parking1;
  Map<String, dynamic>? parking2;
  bool showComparison = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) {

      return StatefulBuilder(
        builder: (context, setModalState) {

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "Compare Parking",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownSearch<Map<String, dynamic>>(
                  items: _parkings.cast<Map<String, dynamic>>(),

                  itemAsString: (item) =>
                      item["parking_name"].toString(),

                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Search Parking 1",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),

                  dropdownDecoratorProps:
                      const DropDownDecoratorProps(
                    dropdownSearchDecoration:
                        InputDecoration(
                      labelText: "Search Parking 1",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  onChanged: (value) {
                    setModalState(() {
                      parking1 = value;
                    });
                  },
                ),

                  const SizedBox(height: 16),

                  DropdownSearch<Map<String, dynamic>>(
                    items: _parkings.cast<Map<String, dynamic>>(),

                    itemAsString: (item) =>
                        item["parking_name"].toString(),

                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: "Search Parking 2",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),

                    dropdownDecoratorProps:
                        const DropDownDecoratorProps(
                      dropdownSearchDecoration:
                          InputDecoration(
                        labelText: "Search Parking 2",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    onChanged: (value) {
                      setModalState(() {
                        parking2 = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                  onPressed: () {

                    if (parking1 == null ||
                        parking2 == null) {
                      return;
                    }

                    setModalState(() {
                      showComparison = true;
                    });
                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ),
                    ),
                    child: const Text(
                      "Compare",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (showComparison &&
                  parking1 != null &&
                  parking2 != null)
                    Column(
                      children: [

                        _compareCard(parking1!),

                        const SizedBox(height: 16),

                        const Text(
                          "VS",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _compareCard(parking2!),

                      ],
                    ),
                                  ],
              ),
            ),
          );
        },
      );
    },
  );
}


                    
Widget _compareCard(
  Map<String, dynamic> parking,
) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          if (parking["image"] != null &&
              parking["image"]
                  .toString()
                  .isNotEmpty)
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),
              child: Image.network(
                parking["image"],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 12),

          Text(
            parking["parking_name"]
                .toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            parking["address"]
                .toString(),
          ),

          const Divider(),

          Text(
            "Car Price : ₹${parking["car_price"]}/hr",
          ),

          Text(
            "Bike Price : ₹${parking["bike_price"]}/hr",
          ),

          Text(
            "Car Slots : ${parking["car_slots"]}",
          ),

          Text(
            "Bike Slots : ${parking["bike_slots"]}",
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final mapLink =
                    parking["map_link"]
                        ?.toString() ??
                    "";

                if (mapLink.isNotEmpty) {
                  launchUrl(
                    Uri.parse(mapLink),
                  );
                }
              },
              child: const Text(
                "Location",
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ══════════════════════════════
      //  DRAWER
      // ══════════════════════════════
      drawer: Drawer(
        child: Column(
          children: [

            // ── Profile header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 55, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [

                  // Avatar with initials
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [

                      if (widget.phone.isNotEmpty)
                        _badge(Icons.phone, widget.phone),

                      if (_isOwner && widget.parkingName.isNotEmpty)
                        _badge(Icons.local_parking, widget.parkingName)
                      else if (!_isOwner && widget.vehicle.isNotEmpty)
                        _badge(Icons.directions_car, widget.vehicle),

                      _badge(
                        _isOwner ? Icons.business : Icons.person,
                        widget.accountType,
                      ),

                    ],
                  ),

                ],
              ),
            ),

            // ── Navigation items ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [

                  _navItem(
                    icon:  Icons.home_outlined,
                    label: "Home",
                    onTap: () => Navigator.pop(context),
                  ),

                  _navItem(
                  icon: Icons.people_outline,
                  label: "My Bookings",
                  onTap: () {

                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserRecordsScreen(),
                      ),
                    );

                  },
                ),

                  _navItem(
                  icon: Icons.business_outlined,
                  label: "Parking Bookings",
                  onTap: () {

                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const OwnerRecordsScreen(),
                      ),
                    );
                  },
                ),

                
                  // Admin Register is intentionally hidden on mobile

                  const Divider(indent: 16, endIndent: 16),

                  _navItem(
                    icon:  Icons.logout,
                    label: "Logout",
                    color: Colors.red.shade600,
                    onTap: _logout,
                  ),

                ],
              ),
            ),

          ],
        ),
      ),

      // ══════════════════════════════
      //  APPBAR
      // ══════════════════════════════
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: const Text(
          "SmartPark",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.20),
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      // ══════════════════════════════
      //  BODY
      // ══════════════════════════════
      body: RefreshIndicator(
        onRefresh: _loadParkings,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Hero banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Smart Parking For Modern Cities",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Find secure parking spaces quickly and manage bookings easily.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showCompareBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.compare_arrows, size: 18),
                      label: const Text(
                        "Compare Parking",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Welcome text ──
              Text(
                "Welcome, ${widget.name} 👋",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (_isOwner && widget.parkingName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_parking, size: 15, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      "Managing: ${widget.parkingName}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // ── Search ──
              TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: "Search Parking...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch("");
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),

              const SizedBox(height: 20),

              // ── Parking list ──
              if (_loadingParkings)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_filteredParkings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.local_parking,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          "No parking found",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredParkings.length,
                  itemBuilder: (context, index) {
                    return ParkingCard(
                    parking: _filteredParkings[index],
                    userName: widget.name,
                    userEmail: widget.email,
                    userPhone: widget.phone,
                    vehicleNumber: widget.vehicle,
                    userId: widget.uniqueId,
                    );
                  },
                ),

            ],
          ),
        ),
      ),
    );
  }

  // ── Drawer nav item ──
  Widget _navItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color? color,
}) {
  final c = color ?? const Color(0xFF0F172A);

  return ListTile(
    leading: Icon(icon, color: c, size: 22),
    title: Text(
      label,
      style: TextStyle(
        color: c,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 2,
    ),
    horizontalTitleGap: 8,
  );
}

  // ── Profile header badge ──
  Widget _badge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}