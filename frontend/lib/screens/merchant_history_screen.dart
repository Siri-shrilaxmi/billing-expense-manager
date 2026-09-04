import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'sign_in_screen.dart';

class MerchantHistoryScreen
    extends StatefulWidget {

  // ============================================================
  // RECEIVER
  // ============================================================

  final int receiverId;

  final String merchantName;

  // ============================================================
  // INITIAL FILTERS
  // ============================================================

  final String initialPeriod;

  final String initialCurrency;

  const MerchantHistoryScreen({
    super.key,

    required this.receiverId,

    required this.merchantName,

    this.initialPeriod = "all",

    this.initialCurrency = "INR",
  });

  @override
  State<MerchantHistoryScreen>
      createState() =>
          _MerchantHistoryScreenState();
}

class _MerchantHistoryScreenState
    extends State<MerchantHistoryScreen> {

  // ============================================================
  // FILTERS
  // ============================================================

  late String selectedPeriod;

  late String selectedCurrency;

  final List<String> periods = const [
    "all",
    "day",
    "week",
    "month",
    "year",
  ];

  final List<String> currencies = const [
    "INR",
    "USD",
    "EUR",
    "GBP",
    "JPY",
    "AED",
    "AUD",
    "CAD",
  ];

  // ============================================================
  // DATA
  // ============================================================

  bool loading = true;

  String? errorMessage;

  Map<String, dynamic> data = {};

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // Validate incoming period.
    // This prevents DropdownButton errors if a bad value
    // is accidentally passed from AnalysisScreen.
    // ----------------------------------------------------------

    selectedPeriod =
        periods.contains(
      widget.initialPeriod,
    )
            ? widget.initialPeriod
            : "all";

    // ----------------------------------------------------------
    // Validate incoming currency.
    // ----------------------------------------------------------

    selectedCurrency =
        currencies.contains(
      widget.initialCurrency,
    )
            ? widget.initialCurrency
            : "INR";

    loadHistory();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> loadHistory() async {

    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {

      final result =
          await ApiService.getMerchantHistory(
        receiverId:
            widget.receiverId,

        period:
            selectedPeriod,

        currency:
            selectedCurrency,
      );

      if (!mounted) {
        return;
      }

      setState(() {

        data = result;

        loading = false;
      });

    } catch (e) {

      if (!mounted) {
        return;
      }

      final message =
          e.toString()
              .replaceFirst(
                "Exception: ",
                "",
              );

      // --------------------------------------------------------
      // SESSION EXPIRED
      // --------------------------------------------------------

      if (message.contains(
        "session has expired",
      )) {

        await ApiService.clearToken();

        if (!mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,

          MaterialPageRoute(
            builder: (_) =>
                const SignInScreen(),
          ),

          (_) => false,
        );

        return;
      }

      setState(() {

        loading = false;

        errorMessage = message;
      });
    }
  }

  // ============================================================
  // CURRENCY SYMBOL
  // ============================================================

  String symbol(
    String currency,
  ) {

    switch (currency) {

      case "INR":
        return "₹";

      case "USD":
        return "\$";

      case "EUR":
        return "€";

      case "GBP":
        return "£";

      case "JPY":
        return "¥";

      case "AED":
        return "د.إ";

      case "AUD":
        return "A\$";

      case "CAD":
        return "C\$";

      default:
        return currency;
    }
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  String amount(
    dynamic value,
  ) {

    final number =
        double.tryParse(
      value?.toString() ?? "",
    );

    if (number == null) {
      return "0.00";
    }

    return number.toStringAsFixed(
      2,
    );
  }

  // ============================================================
  // PERIOD LABEL
  // ============================================================

  String periodLabel(
    String value,
  ) {

    switch (value) {

      case "all":
        return "All";

      case "day":
        return "Today";

      case "week":
        return "This Week";

      case "month":
        return "This Month";

      case "year":
        return "This Year";

      default:
        return value;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar:
          AppBar(

        title:
            Text(
          widget.merchantName,
        ),

        centerTitle:
            true,
      ),

      body:

          loading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : errorMessage != null

                  ? _buildError()

                  : _buildContent(),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {

    return Center(

      child:
          Padding(

        padding:
            const EdgeInsets.all(
          24,
        ),

        child:
            Column(

          mainAxisSize:
              MainAxisSize.min,

          children: [

            const Icon(
              Icons.error_outline,
              size:
                  56,
            ),

            const SizedBox(
              height:
                  16,
            ),

            Text(
              errorMessage ??
                  "Something went wrong.",

              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height:
                  16,
            ),

            ElevatedButton(

              onPressed:
                  loadHistory,

              child:
                  const Text(
                "Retry",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {

    final merchant =
        data["merchant"]
                ?.toString() ??
            widget.merchantName;

    final total =
        amount(
      data["total_amount"],
    );

    final count =
        data["transaction_count"]
                ?.toString() ??
            "0";

    final transactions =
        data["transactions"];

    final List<Map<String, dynamic>>
        transactionList =
        transactions is List
            ? transactions
                .whereType<Map>()
                .map(
                  (item) =>
                      Map<String, dynamic>.from(
                    item,
                  ),
                )
                .toList()
            : [];

    return RefreshIndicator(

      onRefresh:
          loadHistory,

      child:
          ListView(

        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.all(
          16,
        ),

        children: [

          // ======================================================
          // MERCHANT NAME
          // ======================================================

          Text(

            merchant,

            style:
                const TextStyle(
              fontSize:
                  26,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height:
                16,
          ),

          // ======================================================
          // SUMMARY
          // ======================================================

          Row(

            children: [

              Expanded(

                child:
                    _summaryCard(
                  "Total Paid",

                  "${symbol(selectedCurrency)} "
                  "$total",
                ),
              ),

              const SizedBox(
                width:
                    12,
              ),

              Expanded(

                child:
                    _summaryCard(
                  "Transactions",

                  count,
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                20,
          ),

          // ======================================================
          // FILTERS
          // ======================================================

          Row(

            children: [

              // --------------------------------------------------
              // PERIOD
              // --------------------------------------------------

              Expanded(

                child:
                    DropdownButtonFormField<String>(

                  initialValue:
                      selectedPeriod,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Period",

                    border:
                        OutlineInputBorder(),
                  ),

                  items:
                      periods.map(
                    (period) {

                      return DropdownMenuItem<String>(

                        value:
                            period,

                        child:
                            Text(
                          periodLabel(
                            period,
                          ),
                        ),
                      );
                    },
                  ).toList(),

                  onChanged:
                      (value) {

                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedPeriod =
                          value;
                    });

                    loadHistory();
                  },
                ),
              ),

              const SizedBox(
                width:
                    12,
              ),

              // --------------------------------------------------
              // CURRENCY
              // --------------------------------------------------

              Expanded(

                child:
                    DropdownButtonFormField<String>(

                  initialValue:
                      selectedCurrency,

                  decoration:
                      const InputDecoration(
                    labelText:
                        "Currency",

                    border:
                        OutlineInputBorder(),
                  ),

                  items:
                      currencies.map(
                    (currency) {

                      return DropdownMenuItem<String>(

                        value:
                            currency,

                        child:
                            Text(
                          currency,
                        ),
                      );
                    },
                  ).toList(),

                  onChanged:
                      (value) {

                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedCurrency =
                          value;
                    });

                    loadHistory();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                20,
          ),

          // ======================================================
          // TRANSACTION COUNT
          // ======================================================

          Text(

            "${transactionList.length} transaction(s)",

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height:
                10,
          ),

          // ======================================================
          // EMPTY
          // ======================================================

          if (transactionList.isEmpty)

            const Card(

              child:
                  Padding(

                padding:
                    EdgeInsets.all(
                  20,
                ),

                child:
                    Center(
                  child:
                      Text(
                    "No transactions found "
                    "for this receiver in the selected period.",
                  ),
                ),
              ),
            )

          // ======================================================
          // TRANSACTIONS
          // ======================================================

          else

            ...transactionList.map(
              (transaction) {

                final value =
                    amount(
                  transaction["amount"],
                );

                final paymentTime =
                    transaction[
                            "payment_time"]
                        ?.toString();

                final createdAt =
                    transaction[
                            "created_at"]
                        ?.toString();

                final source =
                    transaction[
                            "source"]
                        ?.toString();

                final notes =
                    transaction[
                            "notes"]
                        ?.toString();

                // ------------------------------------------------
                // Scan/save time is the application's timestamp.
                // Bill payment time is the transaction timestamp
                // printed/detected from the bill.
                // ------------------------------------------------

                String subtitle =
                    "Scanned: "
                    "${createdAt ?? "Unknown"}";

                if (paymentTime !=
                        null &&
                    paymentTime.isNotEmpty) {

                  subtitle +=
                      "\nBill date: "
                      "$paymentTime";
                }

                if (source !=
                        null &&
                    source.isNotEmpty) {

                  subtitle +=
                      "\nSource: "
                      "$source";
                }

                if (notes !=
                        null &&
                    notes.isNotEmpty) {

                  subtitle +=
                      "\nNote: "
                      "$notes";
                }

                return Card(

                  margin:
                      const EdgeInsets.only(
                    bottom:
                        8,
                  ),

                  child:
                      ListTile(

                    leading:
                        const CircleAvatar(

                      child:
                          Icon(
                        Icons.receipt_long,
                      ),
                    ),

                    title:
                        Text(

                      "${symbol(selectedCurrency)} "
                      "$value",

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle:
                        Text(
                      subtitle,
                    ),

                    isThreeLine:
                        true,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard(
    String title,
    String value,
  ) {

    return Card(

      child:
          Padding(

        padding:
            const EdgeInsets.all(
          16,
        ),

        child:
            Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              title,

              style:
                  TextStyle(
                color:
                    Colors.grey.shade700,
              ),
            ),

            const SizedBox(
              height:
                  6,
            ),

            Text(

              value,

              style:
                  const TextStyle(
                fontSize:
                    20,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}