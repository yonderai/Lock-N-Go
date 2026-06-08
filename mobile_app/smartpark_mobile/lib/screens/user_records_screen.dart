import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../services/api_service.dart';

class UserRecordsScreen extends StatefulWidget {
  const UserRecordsScreen({super.key});

  @override
  State<UserRecordsScreen> createState() => _UserRecordsScreenState();
}

class _UserRecordsScreenState extends State<UserRecordsScreen> {
  List users = [];
  List records = [];

  bool loadingUsers = true;
  bool loadingRecords = false;

  String? selectedUserId;
  String selectedUserName = "";
  String selectedUserPhone = "";

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final data = await ApiService.getAllUsers();

    setState(() {
      users = data;
      loadingUsers = false;
    });
  }

  Future<void> searchRecords() async {
    if (selectedUserId == null) return;

    setState(() {
      loadingRecords = true;
    });

    final data =
        await ApiService.getUserRecords(selectedUserId!);

    setState(() {
      records = data;
      loadingRecords = false;
    });
  }

  Widget buildStatusBadge(String status) {
    final isPaid =
        status.toLowerCase() == "paid";

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.shade100
            : Colors.orange.shade100,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPaid
              ? Colors.green.shade800
              : Colors.orange.shade800,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildRecordCard(Map record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record["parking_name"] ?? "",
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                buildStatusBadge(
                  record["payment_status"] ??
                      "Paid",
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              "Transaction ID",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            Text(
              "${record["payment_id"]}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        "Date",
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "${record["booking_date"]}",
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        "Amount",
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "₹${record["amount"]}",
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              "Time",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            Text(
              "${record["entry_time"]} → ${record["exit_time"]}",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserCard() {
    return Container(
      margin: const EdgeInsets.only(
        top: 20,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                const Color(0xFF2563EB),
            child: Text(
              selectedUserName.isNotEmpty
                  ? selectedUserName[0]
                      .toUpperCase()
                  : "U",
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  selectedUserName,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedUserPhone,
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
              "Active User",
              style: TextStyle(
                color:
                    Colors.blue.shade800,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xfff5f7fb),

      appBar: AppBar(
        title:
            const Text("User Records"),
        centerTitle: true,
        backgroundColor:
            const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: loadingUsers
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(
                                  0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        DropdownSearch<
                            Map<String,
                                dynamic>>(
                          items: users.cast<
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
                          searchFieldProps: const TextFieldProps(
                            decoration: InputDecoration(
                              hintText: "Search user...",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),

                          dropdownDecoratorProps:
                              const DropDownDecoratorProps(
                            dropdownSearchDecoration:
                                InputDecoration(
                              labelText:
                                  "Select User",
                              border:
                                  OutlineInputBorder(),
                            ),
                          ),

                          onChanged:
                              (selected) {
                            if (selected ==
                                null) {
                              return;
                            }

                            setState(() {
                              selectedUserId =
                                  selected[
                                      "user_id"];

                              selectedUserName =
                                  selected[
                                          "name"] ??
                                      "";

                              selectedUserPhone =
                                  selected[
                                          "phone"] ??
                                      "";
                            });
                          },
                        ),

                        const SizedBox(
                            height: 15),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 50,
                          child:
                              ElevatedButton(
                            onPressed:
                                searchRecords,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xFF2563EB),
                            ),
                            child:
                                const Text(
                              "Search Records",
                              style:
                                  TextStyle(
                                color: Colors
                                    .white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (selectedUserId != null)
                    buildUserCard(),

                  const SizedBox(height: 20),

                  if (loadingRecords)
                    const Center(
                      child:
                          CircularProgressIndicator(),
                    ),

                  if (!loadingRecords &&
                      records.isNotEmpty)
                    Column(
                      children: [
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(16),
                          margin:
                              const EdgeInsets
                                  .only(
                                      bottom:
                                          12),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        16),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              const Text(
                                "Transaction History",
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize:
                                      18,
                                ),
                              ),
                              Text(
                                "${records.length} Records",
                              ),
                            ],
                          ),
                        ),

                        ...records.map(
                          (record) =>
                              buildRecordCard(
                            record
                                as Map,
                          ),
                        ),
                      ],
                    ),

                  if (!loadingRecords &&
                      selectedUserId !=
                          null &&
                      records.isEmpty)
                    Container(
                      margin:
                          const EdgeInsets
                              .only(top: 20),
                      padding:
                          const EdgeInsets
                              .all(25),
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 50,
                            color:
                                Colors.grey,
                          ),
                          SizedBox(
                              height: 10),
                          Text(
                            "No records found",
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}