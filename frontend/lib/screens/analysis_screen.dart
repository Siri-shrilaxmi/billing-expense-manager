import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'merchant_history_screen.dart';
import 'receipt_history_screen.dart';
import 'sign_in_screen.dart';

class AnalysisScreen
    extends StatefulWidget {
  const AnalysisScreen({
    super.key,
  });

  @override
  State<AnalysisScreen> createState() =>
      _AnalysisScreenState();
}

class _AnalysisScreenState
    extends State<AnalysisScreen> {

  // ============================================================
  // FILTERS
  // ============================================================

  String selectedPeriod = "month";

  String selectedCurrency = "INR";

  final List<String> periods = const [
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

  List<Map<String, dynamic>> recentReceipts = [];

  Map<String, dynamic> spendingData = {};

  List<Map<String, dynamic>> merchantData = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadDashboard();
  }

  // ============================================================
  // LOAD DASHBOARD
  // ============================================================

  Future<void> loadDashboard() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      // --------------------------------------------------------
      // RECENT RECEIPTS
      // --------------------------------------------------------

      final recent =
          await ApiService.getRecentReceipts();

      // --------------------------------------------------------
      // SPENDING ANALYSIS
      // --------------------------------------------------------

      final spending =
          await ApiService.getSpendingAnalysis(
        period: selectedPeriod,
        currency: selectedCurrency,
      );

      // --------------------------------------------------------
      // RECEIVER SUMMARY
      // --------------------------------------------------------

      final merchants =
          await ApiService.getMerchantSummary(
        period: selectedPeriod,
        currency: selectedCurrency,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        recentReceipts = recent;
        spendingData = spending;
        merchantData = merchants;
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message =
          e.toString().replaceFirst(
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
            builder: (_) => const SignInScreen(),
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

  String currencySymbol(
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
  // FORMAT MONEY
  // ============================================================

  String formatAmount(
    dynamic value,
  ) {
    if (value == null) {
      return "0.00";
    }

    final number =
        double.tryParse(
      value.toString(),
    );

    if (number == null) {
      return value.toString();
    }

    return number.toStringAsFixed(2);
  }

  // ============================================================
  // PERIOD LABEL
  // ============================================================

  String periodLabel(
    String period,
  ) {
    switch (period) {
      case "day":
        return "Today";

      case "week":
        return "This Week";

      case "year":
        return "This Year";

      case "month":
      default:
        return "This Month";
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
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: loading
            ? _buildLoading()
            : errorMessage != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(
          height: 500,
          child: Center(
            child:
                CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.24,
        ),

        Center(
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color:
                  colorScheme.errorContainer,
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 38,
              color:
                  colorScheme
                      .onErrorContainer,
            ),
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        Text(
          "Unable to load analysis",
          textAlign: TextAlign.center,
          style:
              theme.textTheme.headlineSmall
                  ?.copyWith(
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Text(
            errorMessage ??
                "Something went wrong.",
            textAlign: TextAlign.center,
            style:
                theme.textTheme.bodyMedium
                    ?.copyWith(
              color:
                  colorScheme
                      .onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        Center(
          child:
              FilledButton.icon(
            onPressed:
                loadDashboard,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label:
                const Text(
              "Try Again",
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    return SafeArea(
      child: Center(
        child:
            SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            24,
            22,
            24,
            40,
          ),
          child:
              ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 1120,
            ),
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                _buildHeader(
                  context,
                ),

                const SizedBox(
                  height: 28,
                ),

                // ==================================================
                // OVERVIEW
                // ==================================================

                _buildOverviewHero(
                  context,
                ),

                const SizedBox(
                  height: 32,
                ),

                // ==================================================
                // RECENT
                // ==================================================

                _buildSectionHeader(
                  context,
                  title:
                      "Recent Bills",
                  subtitle:
                      "Your latest scanned receipts",
                  action:
                      TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ReceiptHistoryScreen(
                            initialPeriod:
                                "all",
                            initialCurrency:
                                selectedCurrency,
                          ),
                        ),
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .arrow_forward_rounded,
                      size: 18,
                    ),
                    label:
                        const Text(
                      "View All",
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                _buildRecentSection(
                  context,
                ),

                const SizedBox(
                  height: 36,
                ),

                // ==================================================
                // SPENDING
                // ==================================================

                _buildSectionHeader(
                  context,
                  title:
                      "Spending Analysis",
                  subtitle:
                      "Understand where your money is going",
                ),

                const SizedBox(
                  height: 18,
                ),

                _buildFilters(
                  context,
                ),

                const SizedBox(
                  height: 18,
                ),

                _buildSpendingOverview(
                  context,
                ),

                const SizedBox(
                  height: 18,
                ),

                _buildSpendingGraph(
                  context,
                ),

                const SizedBox(
                  height: 38,
                ),

                // ==================================================
                // RECEIVER SPENDING
                // ==================================================

                _buildSectionHeader(
                  context,
                  title:
                      "Receiver Spending",
                  subtitle:
                      "Total amount paid to each receiver during the selected period.",
                  trailing:
                      _periodPill(
                    context,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                _buildMerchantSection(
                  context,
                ),

                const SizedBox(
                  height: 20,
                ),

                _buildAnalysisNote(
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration:
              BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment.topLeft,
              end:
                  Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ),
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
          child:
              Icon(
            Icons.insights_rounded,
            color:
                colorScheme.onPrimary,
            size: 24,
          ),
        ),

        const SizedBox(
          width: 13,
        ),

        Expanded(
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "Analysis",
                style:
                    theme.textTheme
                        .headlineSmall
                        ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                "A clear view of your spending activity.",
                style:
                    theme.textTheme
                        .bodyMedium
                        ?.copyWith(
                  color:
                      colorScheme
                          .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          tooltip: "Refresh",
          onPressed:
              loading
                  ? null
                  : loadDashboard,
          icon:
              const Icon(
            Icons.refresh_rounded,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW HERO
  // ============================================================

  Widget _buildOverviewHero(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final total =
        formatAmount(
      spendingData["total"],
    );

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        25,
      ),
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            Color.alphaBlend(
              colorScheme.secondary
                  .withOpacity(
                0.35,
              ),
              colorScheme.primary,
            ),
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        boxShadow: [
          BoxShadow(
            color:
                colorScheme.primary
                    .withOpacity(
              0.20,
            ),
            blurRadius: 30,
            offset:
                const Offset(
              0,
              14,
            ),
          ),
        ],
      ),
      child:
          Row(
        children: [
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  periodLabel(
                    selectedPeriod,
                  ),
                  style:
                      theme.textTheme
                          .bodyMedium
                          ?.copyWith(
                    color:
                        colorScheme
                            .onPrimary
                            .withOpacity(
                      0.78,
                    ),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  "Total spending",
                  style:
                      theme.textTheme
                          .headlineSmall
                          ?.copyWith(
                    color:
                        colorScheme
                            .onPrimary,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  "${currencySymbol(selectedCurrency)} $total",
                  style:
                      theme.textTheme
                          .displaySmall
                          ?.copyWith(
                    color:
                        colorScheme
                            .onPrimary,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing:
                        -1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 20,
          ),

          Container(
            width: 82,
            height: 82,
            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(
                0.12,
              ),
              shape:
                  BoxShape.circle,
              border:
                  Border.all(
                color:
                    Colors.white
                        .withOpacity(
                  0.18,
                ),
              ),
            ),
            child:
                Icon(
              Icons
                  .account_balance_wallet_rounded,
              size: 38,
              color:
                  colorScheme
                      .onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? action,
    Widget? trailing,
  }) {
    final theme =
        Theme.of(context);

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        Expanded(
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    theme.textTheme
                        .headlineSmall
                        ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                subtitle,
                style:
                    theme.textTheme
                        .bodySmall
                        ?.copyWith(
                  color:
                      theme.colorScheme
                          .onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        if (action != null)
          action,

        if (trailing != null)
          trailing,
      ],
    );
  }

  // ============================================================
  // RECENT SECTION
  // ============================================================

  Widget _buildRecentSection(
    BuildContext context,
  ) {
    if (recentReceipts.isEmpty) {
      return _buildEmptyState(
        context,
        icon:
            Icons.receipt_long_outlined,
        title:
            "No receipts yet",
        description:
            "Your latest scanned bills will appear here.",
      );
    }

    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      width:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
      child:
          Column(
        children:
            List.generate(
          recentReceipts.length,
          (index) {
            final receipt =
                recentReceipts[index];

            return _buildRecentItem(
              context,
              receipt,
              index ==
                  recentReceipts.length -
                      1,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // RECENT ITEM
  // ============================================================

  Widget _buildRecentItem(
    BuildContext context,
    Map<String, dynamic> receipt,
    bool last,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final merchant =
        receipt["merchant"]
                ?.toString() ??
            "Unknown";

    final currency =
        receipt["currency"]
                ?.toString() ??
            selectedCurrency;

    final amount =
        formatAmount(
      receipt["amount"],
    );

    final createdAt =
        receipt["created_at"]
            ?.toString();

    final paymentTime =
        receipt["payment_time"]
            ?.toString();

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        17,
        16,
        17,
        16,
      ),
      decoration:
          BoxDecoration(
        border:
            last
                ? null
                : Border(
                    bottom:
                        BorderSide(
                      color:
                          colorScheme
                              .outlineVariant,
                    ),
                  ),
      ),
      child:
          Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              color:
                  colorScheme
                      .primaryContainer,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child:
                Icon(
              Icons.receipt_long_rounded,
              color:
                  colorScheme
                      .onPrimaryContainer,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  merchant,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      theme.textTheme
                          .titleMedium
                          ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _recentDateText(
                    createdAt,
                    paymentTime,
                  ),
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      theme.textTheme
                          .bodySmall
                          ?.copyWith(
                    color:
                        colorScheme
                            .onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Text(
            "${currencySymbol(currency)} $amount",
            style:
                theme.textTheme
                    .titleSmall
                    ?.copyWith(
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _recentDateText(
    String? createdAt,
    String? paymentTime,
  ) {
    if (createdAt != null &&
        createdAt.isNotEmpty) {
      if (paymentTime != null &&
          paymentTime.isNotEmpty) {
        return "Scanned: $createdAt\nBill date: $paymentTime";
      }

      return "Scanned: $createdAt";
    }

    if (paymentTime != null &&
        paymentTime.isNotEmpty) {
      return "Bill date: $paymentTime";
    }

    return "Scan time unavailable";
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child:
              DropdownButtonFormField<
                  String>(
            initialValue:
                selectedPeriod,
            decoration:
                const InputDecoration(
              labelText:
                  "Period",
              prefixIcon:
                  Icon(
                Icons
                    .calendar_today_outlined,
              ),
            ),
            items:
                periods.map(
              (period) {
                return DropdownMenuItem<
                    String>(
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

              loadDashboard();
            },
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child:
              DropdownButtonFormField<
                  String>(
            initialValue:
                selectedCurrency,
            decoration:
                const InputDecoration(
              labelText:
                  "Currency",
              prefixIcon:
                  Icon(
                Icons
                    .currency_exchange_outlined,
              ),
            ),
            items:
                currencies.map(
              (currency) {
                return DropdownMenuItem<
                    String>(
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

              loadDashboard();
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SPENDING OVERVIEW
  // ============================================================

  Widget _buildSpendingOverview(
    BuildContext context,
  ) {
    final total =
        formatAmount(
      spendingData["total"],
    );

    final raw =
        spendingData["data"];

    final count =
        raw is List
            ? raw.length
            : 0;

    return Row(
      children: [
        Expanded(
          child:
              _buildMetric(
            context,
            icon:
                Icons.payments_outlined,
            label:
                "Total",
            value:
                "${currencySymbol(selectedCurrency)} $total",
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child:
              _buildMetric(
            context,
            icon:
                Icons.timeline_outlined,
            label:
                "Data points",
            value:
                "$count",
          ),
        ),
      ],
    );
  }

  // ============================================================
  // METRIC
  // ============================================================

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          19,
        ),
        border:
            Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
      child:
          Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  colorScheme
                      .primaryContainer,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child:
                Icon(
              icon,
              size: 21,
              color:
                  colorScheme
                      .onPrimaryContainer,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  label,
                  style:
                      theme.textTheme
                          .bodySmall
                          ?.copyWith(
                    color:
                        colorScheme
                            .onSurfaceVariant,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      theme.textTheme
                          .titleLarge
                          ?.copyWith(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SPENDING GRAPH
  // ============================================================

  Widget _buildSpendingGraph(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final raw =
        spendingData["data"];

    if (raw is! List ||
        raw.isEmpty) {
      return _buildEmptyState(
        context,
        icon:
            Icons.bar_chart_outlined,
        title:
            "No spending data",
        description:
            "There is no spending data for this period.",
      );
    }

    final rows =
        raw
            .map(
              (item) =>
                  Map<String, dynamic>.from(
                item as Map,
              ),
            )
            .toList();

    double maxValue = 0;

    for (final row in rows) {
      final value =
          double.tryParse(
        row["total"]
                ?.toString() ??
            "0",
      ) ??
          0;

      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 0) {
      return _buildEmptyState(
        context,
        icon:
            Icons.bar_chart_outlined,
        title:
            "No spending data",
        description:
            "There is no spending recorded for this period.",
      );
    }

    final double itemWidth =
        rows.length <= 7
            ? 100
            : 76;

    final double graphWidth =
        rows.length * itemWidth;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        18,
        20,
        18,
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          23,
        ),
        border:
            Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            children: [
              Text(
                "Spending trend",
                style:
                    theme.textTheme
                        .titleMedium
                        ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const Spacer(),

              Text(
                periodLabel(
                  selectedPeriod,
                ),
                style:
                    theme.textTheme
                        .bodySmall
                        ?.copyWith(
                  color:
                      colorScheme
                          .onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          SizedBox(
            height: 270,
            child:
                SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child:
                  SizedBox(
                width:
                    graphWidth < 600
                        ? 600
                        : graphWidth,
                child:
                    _buildGraphBars(
                  context,
                  rows,
                  maxValue,
                  itemWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRAPH BARS
  // ============================================================

  Widget _buildGraphBars(
    BuildContext context,
    List<Map<String, dynamic>>
        rows,
    double maxValue,
    double itemWidth,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    final double barWidth =
        rows.length <= 7
            ? 42
            : 34;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children:
          rows.map(
        (row) {
          final value =
              double.tryParse(
            row["total"]
                    ?.toString() ??
                "0",
          ) ??
              0;

          final ratio =
              (value / maxValue)
                  .clamp(
            0.0,
            1.0,
          )
                  .toDouble();

          final double barHeight =
              ratio * 185;

          final label =
              row["label"]
                      ?.toString() ??
                  "";

          return SizedBox(
            width:
                itemWidth,
            height:
                250,
            child:
                Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .end,
              children: [
                SizedBox(
                  height: 24,
                  child:
                      value > 0
                          ? Text(
                              formatAmount(
                                value,
                              ),
                              textAlign:
                                  TextAlign.center,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 9,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            )
                          : null,
                ),

                const SizedBox(
                  height: 5,
                ),

                Container(
                  width:
                      barWidth,
                  height:
                      barHeight,
                  decoration:
                      BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment
                              .bottomCenter,
                      end:
                          Alignment
                              .topCenter,
                      colors: [
                        colorScheme
                            .primary,
                        colorScheme
                            .secondary,
                      ],
                    ),
                    borderRadius:
                        const BorderRadius
                            .vertical(
                      top:
                          Radius.circular(
                        8,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                SizedBox(
                  height: 28,
                  child:
                      Text(
                    label,
                    textAlign:
                        TextAlign.center,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // PERIOD PILL
  // ============================================================

  Widget _periodPill(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme
                .primaryContainer,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child:
          Text(
        periodLabel(
          selectedPeriod,
        ),
        style:
            TextStyle(
          color:
              colorScheme
                  .onPrimaryContainer,
          fontSize: 12,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // RECEIVER SPENDING
  // ============================================================

  Widget _buildMerchantSection(
    BuildContext context,
  ) {
    if (merchantData.isEmpty) {
      return _buildEmptyState(
        context,
        icon:
            Icons.store_outlined,
        title:
            "No receiver spending",
        description:
            "No receiver has spending recorded during this period.",
      );
    }

    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      width:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          23,
        ),
        border:
            Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
      child:
          Column(
        children:
            List.generate(
          merchantData.length,
          (index) {
            final receiver =
                merchantData[index];

            return _buildReceiverItem(
              context,
              receiver,
              index,
              index ==
                  merchantData.length -
                      1,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // RECEIVER ITEM
  // ============================================================

  Widget _buildReceiverItem(
    BuildContext context,
    Map<String, dynamic> receiver,
    int index,
    bool last,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final receiverId =
        int.tryParse(
      receiver["receiver_id"]
              ?.toString() ??
          "",
    );

    final receiverName =
        receiver["merchant"]
                ?.toString() ??
            "Unknown";

    final total =
        formatAmount(
      receiver["total_amount"],
    );

    final currency =
        receiver["currency"]
                ?.toString() ??
            selectedCurrency;

    final count =
        receiver["transaction_count"]
                ?.toString() ??
            "0";

    return Material(
      color:
          Colors.transparent,
      child:
          InkWell(
        onTap:
            receiverId == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MerchantHistoryScreen(
                          receiverId:
                              receiverId,
                          merchantName:
                              receiverName,
                          initialPeriod:
                              selectedPeriod,
                          initialCurrency:
                              selectedCurrency,
                        ),
                      ),
                    );
                  },
        child:
            Container(
          padding:
              const EdgeInsets.fromLTRB(
            17,
            17,
            15,
            17,
          ),
          decoration:
              BoxDecoration(
            border:
                last
                    ? null
                    : Border(
                        bottom:
                            BorderSide(
                          color:
                              colorScheme
                                  .outlineVariant,
                        ),
                      ),
          ),
          child:
              Row(
            children: [
              // ------------------------------------------------
              // RANK
              // ------------------------------------------------

              Container(
                width: 34,
                height: 34,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      colorScheme
                          .primaryContainer,
                  shape:
                      BoxShape.circle,
                ),
                child:
                    Text(
                  "${index + 1}",
                  style:
                      TextStyle(
                    color:
                        colorScheme
                            .onPrimaryContainer,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // ------------------------------------------------
              // INFORMATION
              // ------------------------------------------------

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      receiverName,
                      maxLines:
                          1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          theme.textTheme
                              .titleMedium
                              ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      "$count transaction"
                      "${count == "1" ? "" : "s"}",
                      style:
                          theme.textTheme
                              .bodySmall
                              ?.copyWith(
                        color:
                            colorScheme
                                .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // ------------------------------------------------
              // TOTAL
              // ------------------------------------------------

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .end,
                children: [
                  Text(
                    "${currencySymbol(currency)} $total",
                    style:
                        theme.textTheme
                            .titleSmall
                            ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        "Details",
                        style:
                            theme.textTheme
                                .bodySmall
                                ?.copyWith(
                          color:
                              colorScheme
                                  .primary,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        width: 3,
                      ),

                      Icon(
                        Icons
                            .arrow_forward_rounded,
                        size: 15,
                        color:
                            colorScheme
                                .primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
      child:
          Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  colorScheme
                      .primaryContainer,
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              icon,
              color:
                  colorScheme
                      .onPrimaryContainer,
              size: 26,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Text(
            title,
            style:
                theme.textTheme
                    .titleMedium
                    ?.copyWith(
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            description,
            textAlign:
                TextAlign.center,
            style:
                theme.textTheme
                    .bodySmall
                    ?.copyWith(
              color:
                  colorScheme
                      .onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANALYSIS NOTE
  // ============================================================

  Widget _buildAnalysisNote(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme
                .surfaceVariant,
        borderRadius:
            BorderRadius.circular(
          15,
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 19,
            color:
                colorScheme.primary,
          ),

          const SizedBox(
            width: 9,
          ),

          Expanded(
            child:
                Text(
              "Analysis is based on the time the receipt was scanned and saved in the application.",
              style:
                  theme.textTheme
                      .bodySmall
                      ?.copyWith(
                color:
                    colorScheme
                        .onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}