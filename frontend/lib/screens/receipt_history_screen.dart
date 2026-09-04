import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'sign_in_screen.dart';

class ReceiptHistoryScreen
    extends StatefulWidget {

  // ============================================================
  // INITIAL FILTERS
  // ============================================================

  final String initialPeriod;

  final String initialCurrency;

  const ReceiptHistoryScreen({
    super.key,

    // "all" is used when opening from View All.
    this.initialPeriod = "all",

    // Default currency.
    this.initialCurrency = "INR",
  });

  @override
  State<ReceiptHistoryScreen>
      createState() =>
          _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState
    extends State<ReceiptHistoryScreen> {

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

  List<Map<String, dynamic>> receipts = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // Receive the filters from AnalysisScreen.
    // ----------------------------------------------------------

    selectedPeriod =
        widget.initialPeriod;

    selectedCurrency =
        widget.initialCurrency;

    loadHistory();
  }

  // ============================================================
  // LOAD HISTORY
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
          await ApiService.getReceiptHistory(
        period:
            selectedPeriod,
        currency:
            selectedCurrency,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        receipts = result;
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

    final parsed =
        double.tryParse(
      value?.toString() ?? "",
    );

    if (parsed == null) {
      return "0.00";
    }

    return parsed.toStringAsFixed(
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
            const Text(
          "All Bills",
        ),

        centerTitle:
            true,
      ),

      body:
          RefreshIndicator(

        onRefresh:
            loadHistory,

        child:
            loading

                ? ListView(

                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    children: const [

                      SizedBox(
                        height:
                            300,

                        child:
                            Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  )

                : errorMessage !=
                        null

                    ? _buildError()

                    : _buildContent(),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {

    return ListView(

      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.all(
        24,
      ),

      children: [

        const SizedBox(
          height:
              100,
        ),

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
              20,
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
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {

    return ListView(

      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.all(
        16,
      ),

      children: [

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
              16,
        ),

        // ======================================================
        // RESULT COUNT
        // ======================================================

        Text(
          "${receipts.length} bill(s)",

          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height:
              8,
        ),

        // ======================================================
        // EMPTY RESULT
        // ======================================================

        if (receipts.isEmpty)

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
                  "No bills found.",
                ),
              ),
            ),
          ),

        // ======================================================
        // RECEIPTS
        // ======================================================

        ...receipts.map(
          (receipt) {

            final merchant =
                receipt["merchant"]
                        ?.toString() ??
                    "Unknown";

            final currency =
                receipt["currency"]
                        ?.toString() ??
                    selectedCurrency;

            final createdAt =
                receipt["created_at"]
                    ?.toString();

            final paymentTime =
                receipt["payment_time"]
                    ?.toString();

            final receiptAmount =
                amount(
              receipt["amount"],
            );

            // --------------------------------------------------
            // Build date information separately so that:
            //
            // created_at  = when user scanned/saved it
            // payment_time = date from the actual bill
            // --------------------------------------------------

            String subtitle =
                "Scanned: "
                "${createdAt ?? "Unknown"}";

            if (paymentTime != null &&
                paymentTime.isNotEmpty) {

              subtitle +=
                  "\nBill date: "
                  "$paymentTime";
            }

            return Card(

              margin:
                  const EdgeInsets.only(
                bottom:
                    10,
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
                  merchant,
                ),

                subtitle:
                    Text(
                  subtitle,
                ),

                isThreeLine:
                    true,

                trailing:
                    Text(

                  "${symbol(currency)} "
                  "$receiptAmount",

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}