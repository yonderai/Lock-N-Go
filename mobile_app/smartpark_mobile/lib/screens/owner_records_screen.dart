import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

class OwnerRecordsScreen extends StatefulWidget {
const OwnerRecordsScreen({super.key});

@override
State<OwnerRecordsScreen> createState() =>
_OwnerRecordsScreenState();
}

class _OwnerRecordsScreenState
extends State<OwnerRecordsScreen> {
List owners = [];
List records = [];

bool loadingOwners = true;
bool loadingRecords = false;

String? selectedOwnerId;
String selectedOwnerName = "";
String selectedOwnerPhone = "";
String selectedParkingName = "";

@override
void initState() {
super.initState();
loadOwners();
}

Future<void> loadOwners() async {
final data = await ApiService.getOwners();

//
setState(() {
  owners = data;
  loadingOwners = false;
});
//

}

Future<void> searchRecords() async {
if (selectedOwnerId == null) return;

//
setState(() {
  loadingRecords = true;
});

final data =
    await ApiService.getOwnerRecords(
  selectedOwnerId!,
);

setState(() {
  records = data;
  loadingRecords = false;
});
//

}

Widget statusBadge(String status) {
final paid =
status.toLowerCase() == "paid";

//
return Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    color: paid
        ? Colors.green.shade100
        : Colors.orange.shade100,
    borderRadius:
        BorderRadius.circular(20),
  ),
  child: Text(
    status,
    style: TextStyle(
      color: paid
          ? Colors.green.shade800
          : Colors.orange.shade800,
      fontWeight: FontWeight.bold,
    ),
  ),
);
//

}

Widget buildOwnerCard() {
return Container(
margin: const EdgeInsets.only(top: 16),
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color:
Colors.black.withOpacity(.05),
blurRadius: 10,
)
],
),
child: Row(
children: [
CircleAvatar(
radius: 28,
backgroundColor:
const Color(0xFF0284C7),
child: Text(
selectedOwnerName.isNotEmpty
? selectedOwnerName
.substring(0, 1)
.toUpperCase()
: "O",
style: const TextStyle(
color: Colors.white,
fontWeight:
FontWeight.bold,
fontSize: 22,
),
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
selectedOwnerName,
style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
const SizedBox(height: 4),
Text(selectedOwnerPhone),
const SizedBox(height: 4),
Text(
selectedParkingName,
style: const TextStyle(
color:
Color(0xFF2563EB),
fontWeight:
FontWeight.w600,
),
),
],
),
),
Container(
padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 6,
),
decoration: BoxDecoration(
color:
Colors.blue.shade100,
borderRadius:
BorderRadius.circular(
20),
),
child: Text(
"Parking Owner",
style: TextStyle(
color:
Colors.blue.shade800,
fontWeight:
FontWeight.bold,
),
),
)
],
),
);
}

Widget buildRecordCard(Map record) {
return Container(
margin:
const EdgeInsets.only(bottom: 14),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color:
Colors.black.withOpacity(.05),
blurRadius: 10,
)
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

//
      Row(
        children: [
          Expanded(
            child: Text(
              record["user_name"] ??
                  "",
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          statusBadge(
            record[
                    "payment_status"] ??
                "Paid",
          ),
        ],
      ),

      const SizedBox(height: 12),

      Text(
        "Transaction ID",
        style: TextStyle(
          color:
              Colors.grey.shade600,
        ),
      ),
      Text(
        "${record["payment_id"]}",
      ),

      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: info(
              "Phone",
              record["user_phone"]
                      ?.toString() ??
                  "",
            ),
          ),
          Expanded(
            child: info(
              "Vehicle",
              record["vehicle_number"]
                      ?.toString() ??
                  "",
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      Row(
        children: [
          Expanded(
            child: info(
              "Date",
              record["booking_date"]
                      ?.toString() ??
                  "",
            ),
          ),
          Expanded(
            child: info(
              "Amount",
              "₹${record["amount"]}",
            ),
          ),
        ],
      ),

      const SizedBox(height: 12),

      info(
        "Time",
        "${record["entry_time"]} → ${record["exit_time"]}",
      ),
    ],
  ),
);
//

}

Widget info(
String title,
String value,
) {
return Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: TextStyle(
color:
Colors.grey.shade600,
fontSize: 12,
),
),
Text(
value,
style: const TextStyle(
fontWeight:
FontWeight.w600,
),
)
],
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor:
const Color(0xFFF5F7FB),

//
  appBar: AppBar(
    title:
        const Text("Owner Records"),
    backgroundColor:
        const Color(0xFF2563EB),
    foregroundColor:
        Colors.white,
  ),

  body: loadingOwners
      ? const Center(
          child:
              CircularProgressIndicator(),
        )
      : SingleChildScrollView(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [

              Container(
                padding:
                    const EdgeInsets.all(
                        16),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),
                child: Column(
                  children: [

                    DropdownSearch<
    Map<String,
        dynamic>>(
  items: owners.cast<
      Map<String,
          dynamic>>(),

  itemAsString:
      (item) =>
          "${item["name"]} - ${item["phone"]}",

  popupProps: PopupProps.menu(
    showSearchBox: true,
    fit: FlexFit.loose,
    constraints: const BoxConstraints(
      maxHeight: 250,
    ),
    searchFieldProps:
        const TextFieldProps(
      decoration:
          InputDecoration(
        hintText:
            "Search owner...",
        prefixIcon:
            Icon(Icons.search),
        border:
            OutlineInputBorder(),
      ),
    ),
  ),

  dropdownDecoratorProps:
      const DropDownDecoratorProps(
    dropdownSearchDecoration:
        InputDecoration(
      labelText:
          "Select Owner",
      border:
          OutlineInputBorder(),
    ),
  ),

  onChanged:
      (selected) {
    if (selected == null) {
      return;
    }

    setState(() {
      selectedOwnerId =
          selected["owner_id"];

      selectedOwnerName =
          selected["name"] ??
              "";

      selectedOwnerPhone =
          selected["phone"] ??
              "";

      selectedParkingName =
          selected["parking_name"] ??
              "";
    });
  },
),

                    const SizedBox(
                        height: 16),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          ElevatedButton(
                        onPressed:
                            searchRecords,
                        child:
                            const Text(
                          "Search",
                        ),
                      ),
                    )
                  ],
                ),
              ),

              if (selectedOwnerId != null)
                buildOwnerCard(),

              const SizedBox(height: 20),

              if (loadingRecords)
                const CircularProgressIndicator(),

              if (!loadingRecords &&
                  records.isNotEmpty)
                Column(
                  children: [
                    Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        "Booking Transactions (${records.length})",
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 12),
                    ...records.map(
                      (e) =>
                          buildRecordCard(
                        e as Map,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
);
//

}
}
