package com.billmanagement.backend.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Month;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class AnalysisService {

    private final JdbcTemplate jdbcTemplate;

    /*
     * All analysis periods are calculated using
     * Indian Standard Time.
     */
    private static final ZoneId INDIA_ZONE =
            ZoneId.of("Asia/Kolkata");

    public AnalysisService(
            JdbcTemplate jdbcTemplate
    ) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // ============================================================
    // RECENT RECEIPTS
    //
    // Shows the latest 3 receipts based on application scan/save
    // time, NOT the date printed on the bill.
    // ============================================================

    public List<Map<String, Object>> getRecentReceipts(
            Long userId
    ) {

        return jdbcTemplate.query(
                """
                SELECT
                    p.payment_id,
                    r.receiver_id,
                    r.name AS merchant,
                    p.amount,
                    p.currency,
                    p.payment_time,
                    p.created_at,
                    p.source,
                    p.notes
                FROM payment p
                JOIN receiver r
                    ON r.receiver_id = p.receiver_id
                WHERE
                    p.user_id = ?
                ORDER BY
                    p.created_at DESC,
                    p.payment_id DESC
                LIMIT 3
                """,

                (rs, rowNum) ->
                        mapPaymentRow(rs),

                userId
        );
    }

    // ============================================================
    // FULL RECEIPT HISTORY
    //
    // "all" means all records for the user.
    //
    // For day/week/month/year:
    // filtering is based on created_at.
    // ============================================================

    public List<Map<String, Object>> getHistory(
            Long userId,
            String period,
            String currency
    ) {

        String normalizedPeriod =
                normalizePeriod(period);

        if (normalizedPeriod.equals("all")) {

            return jdbcTemplate.query(
                    """
                    SELECT
                        p.payment_id,
                        r.receiver_id,
                        r.name AS merchant,
                        p.amount,
                        p.currency,
                        p.payment_time,
                        p.created_at,
                        p.source,
                        p.notes
                    FROM payment p
                    JOIN receiver r
                        ON r.receiver_id = p.receiver_id
                    WHERE
                        p.user_id = ?
                        AND p.currency = ?
                    ORDER BY
                        p.created_at DESC,
                        p.payment_id DESC
                    """,

                    (rs, rowNum) ->
                            mapPaymentRow(rs),

                    userId,
                    currency
            );
        }

        PeriodRange range =
                calculatePeriodRange(
                        normalizedPeriod
                );

        return jdbcTemplate.query(
                """
                SELECT
                    p.payment_id,
                    r.receiver_id,
                    r.name AS merchant,
                    p.amount,
                    p.currency,
                    p.payment_time,
                    p.created_at,
                    p.source,
                    p.notes
                FROM payment p
                JOIN receiver r
                    ON r.receiver_id = p.receiver_id
                WHERE
                    p.user_id = ?
                    AND p.created_at >= ?
                    AND p.created_at < ?
                    AND p.currency = ?
                ORDER BY
                    p.created_at DESC,
                    p.payment_id DESC
                """,

                (rs, rowNum) ->
                        mapPaymentRow(rs),

                userId,
                range.start(),
                range.end(),
                currency
        );
    }

    // ============================================================
    // SPENDING ANALYSIS
    //
    // The selected period refers to scan/save time.
    //
    // day   -> hourly spending for today
    // week  -> daily spending for this week
    // month -> daily spending for this month
    // year  -> monthly spending for this year
    //
    // "all" is not used by the graph screen.
    // ============================================================

    public Map<String, Object> getAnalytics(
            Long userId,
            String period,
            String currency
    ) {

        String normalizedPeriod =
                normalizePeriod(period);

        if (normalizedPeriod.equals("all")) {
            normalizedPeriod = "month";
        }

        PeriodRange range =
                calculatePeriodRange(
                        normalizedPeriod
                );

        String groupingExpression =
                getGroupingExpression(
                        normalizedPeriod
                );

        String labelExpression =
                getLabelExpression(
                        normalizedPeriod
                );

        String sql = """
                SELECT
                    %s AS bucket,
                    %s AS label,
                    SUM(p.amount) AS total
                FROM payment p
                WHERE
                    p.user_id = ?
                    AND p.created_at >= ?
                    AND p.created_at < ?
                    AND p.currency = ?
                GROUP BY
                    %s,
                    %s
                ORDER BY
                    %s
                """.formatted(
                groupingExpression,
                labelExpression,
                groupingExpression,
                labelExpression,
                groupingExpression
        );

        List<Map<String, Object>> rows =
                jdbcTemplate.query(
                        sql,

                        (rs, rowNum) -> {

                            Map<String, Object> row =
                                    new LinkedHashMap<>();

                            row.put(
                                    "bucket",
                                    rs.getString(
                                            "bucket"
                                    )
                            );

                            row.put(
                                    "label",
                                    rs.getString(
                                            "label"
                                    )
                            );

                            row.put(
                                    "total",
                                    rs.getBigDecimal(
                                            "total"
                                    )
                            );

                            return row;
                        },

                        userId,
                        range.start(),
                        range.end(),
                        currency
                );

        BigDecimal total =
                rows.stream()
                        .map(
                                row ->
                                        (BigDecimal)
                                                row.get(
                                                        "total"
                                                )
                        )
                        .reduce(
                                BigDecimal.ZERO,
                                BigDecimal::add
                        );

        Map<String, Object> result =
                new LinkedHashMap<>();

        result.put(
                "period",
                normalizedPeriod
        );

        result.put(
                "currency",
                currency
        );

        result.put(
                "total",
                total
        );

        result.put(
                "data",
                rows
        );

        return result;
    }

    // ============================================================
    // RECEIVER SPENDING SUMMARY
    //
    // Each receiver appears once.
    //
    // Example:
    //
    // Shop XYZ     ₹25,000
    // Hotel ABC     ₹3,200
    //
    // Sorted by total amount DESC.
    //
    // The period refers to created_at.
    // ============================================================

    public List<Map<String, Object>> getMerchantSummary(
            Long userId,
            String period,
            String currency
    ) {

        String normalizedPeriod =
                normalizePeriod(period);

        if (normalizedPeriod.equals("all")) {
            normalizedPeriod = "month";
        }

        PeriodRange range =
                calculatePeriodRange(
                        normalizedPeriod
                );

        return jdbcTemplate.query(
                """
                SELECT
                    r.receiver_id,
                    r.name AS merchant,
                    COUNT(p.payment_id)
                        AS transaction_count,
                    SUM(p.amount)
                        AS total_amount,
                    p.currency
                FROM payment p
                JOIN receiver r
                    ON r.receiver_id = p.receiver_id
                WHERE
                    p.user_id = ?
                    AND p.created_at >= ?
                    AND p.created_at < ?
                    AND p.currency = ?
                GROUP BY
                    r.receiver_id,
                    r.name,
                    p.currency
                ORDER BY
                    total_amount DESC,
                    r.name ASC
                """,

                (rs, rowNum) -> {

                    Map<String, Object> row =
                            new LinkedHashMap<>();

                    row.put(
                            "receiver_id",
                            rs.getLong(
                                    "receiver_id"
                            )
                    );

                    row.put(
                            "merchant",
                            rs.getString(
                                    "merchant"
                            )
                    );

                    row.put(
                            "transaction_count",
                            rs.getLong(
                                    "transaction_count"
                            )
                    );

                    row.put(
                            "total_amount",
                            rs.getBigDecimal(
                                    "total_amount"
                            )
                    );

                    row.put(
                            "currency",
                            rs.getString(
                                    "currency"
                            )
                    );

                    return row;
                },

                userId,
                range.start(),
                range.end(),
                currency
        );
    }

    // ============================================================
    // RECEIVER HISTORY
    //
    // Shows every payment made to ONE receiver.
    //
    // "all" = every payment to that receiver.
    //
    // For day/week/month/year:
    // filtering uses created_at.
    //
    // Sorting always uses created_at DESC.
    // ============================================================

    public Map<String, Object> getMerchantHistory(
            Long userId,
            Long receiverId,
            String period,
            String currency
    ) {

        String normalizedPeriod =
                normalizePeriod(period);

        /*
         * Confirm that the receiver exists.
         *
         * The actual transaction query below still restricts
         * records using p.user_id, so another user's payments
         * cannot be returned.
         */
        Map<String, Object> merchant =
                jdbcTemplate.queryForMap(
                        """
                        SELECT
                            receiver_id,
                            name
                        FROM receiver
                        WHERE
                            receiver_id = ?
                        """,

                        receiverId
                );

        List<Map<String, Object>> transactions;

        if (normalizedPeriod.equals("all")) {

            transactions =
                    jdbcTemplate.query(
                            """
                            SELECT
                                p.payment_id,
                                p.amount,
                                p.currency,
                                p.payment_time,
                                p.created_at,
                                p.source,
                                p.notes
                            FROM payment p
                            WHERE
                                p.user_id = ?
                                AND p.receiver_id = ?
                                AND p.currency = ?
                            ORDER BY
                                p.created_at DESC,
                                p.payment_id DESC
                            """,

                            (rs, rowNum) ->
                                    mapTransactionRow(rs),

                            userId,
                            receiverId,
                            currency
                    );

        } else {

            PeriodRange range =
                    calculatePeriodRange(
                            normalizedPeriod
                    );

            transactions =
                    jdbcTemplate.query(
                            """
                            SELECT
                                p.payment_id,
                                p.amount,
                                p.currency,
                                p.payment_time,
                                p.created_at,
                                p.source,
                                p.notes
                            FROM payment p
                            WHERE
                                p.user_id = ?
                                AND p.receiver_id = ?
                                AND p.created_at >= ?
                                AND p.created_at < ?
                                AND p.currency = ?
                            ORDER BY
                                p.created_at DESC,
                                p.payment_id DESC
                            """,

                            (rs, rowNum) ->
                                    mapTransactionRow(rs),

                            userId,
                            receiverId,
                            range.start(),
                            range.end(),
                            currency
                    );
        }

        BigDecimal total =
                transactions.stream()
                        .map(
                                row ->
                                        (BigDecimal)
                                                row.get(
                                                        "amount"
                                                )
                        )
                        .reduce(
                                BigDecimal.ZERO,
                                BigDecimal::add
                        );

        Map<String, Object> result =
                new LinkedHashMap<>();

        result.put(
                "receiver_id",
                receiverId
        );

        result.put(
                "merchant",
                merchant.get(
                        "name"
                )
        );

        result.put(
                "currency",
                currency
        );

        result.put(
                "total_amount",
                total
        );

        result.put(
                "transaction_count",
                transactions.size()
        );

        result.put(
                "transactions",
                transactions
        );

        return result;
    }

    // ============================================================
    // MAP COMPLETE PAYMENT ROW
    // ============================================================

    private Map<String, Object> mapPaymentRow(
            ResultSet rs
    ) throws SQLException {

        Map<String, Object> row =
                new LinkedHashMap<>();

        row.put(
                "payment_id",
                rs.getLong(
                        "payment_id"
                )
        );

        row.put(
                "receiver_id",
                rs.getLong(
                        "receiver_id"
                )
        );

        row.put(
                "merchant",
                rs.getString(
                        "merchant"
                )
        );

        row.put(
                "amount",
                rs.getBigDecimal(
                        "amount"
                )
        );

        row.put(
                "currency",
                rs.getString(
                        "currency"
                )
        );

        Timestamp paymentTime =
                rs.getTimestamp(
                        "payment_time"
                );

        Timestamp createdAt =
                rs.getTimestamp(
                        "created_at"
                );

        row.put(
                "payment_time",
                paymentTime == null
                        ? null
                        : paymentTime
                                .toLocalDateTime()
                                .toString()
        );

        row.put(
                "created_at",
                createdAt == null
                        ? null
                        : createdAt
                                .toLocalDateTime()
                                .toString()
        );

        row.put(
                "source",
                rs.getString(
                        "source"
                )
        );

        row.put(
                "notes",
                rs.getString(
                        "notes"
                )
        );

        return row;
    }

    // ============================================================
    // MAP TRANSACTION ROW
    // ============================================================

    private Map<String, Object> mapTransactionRow(
            ResultSet rs
    ) throws SQLException {

        Map<String, Object> row =
                new LinkedHashMap<>();

        row.put(
                "payment_id",
                rs.getLong(
                        "payment_id"
                )
        );

        row.put(
                "amount",
                rs.getBigDecimal(
                        "amount"
                )
        );

        row.put(
                "currency",
                rs.getString(
                        "currency"
                )
        );

        Timestamp paymentTime =
                rs.getTimestamp(
                        "payment_time"
                );

        Timestamp createdAt =
                rs.getTimestamp(
                        "created_at"
                );

        row.put(
                "payment_time",
                paymentTime == null
                        ? null
                        : paymentTime
                                .toLocalDateTime()
                                .toString()
        );

        row.put(
                "created_at",
                createdAt == null
                        ? null
                        : createdAt
                                .toLocalDateTime()
                                .toString()
        );

        row.put(
                "source",
                rs.getString(
                        "source"
                )
        );

        row.put(
                "notes",
                rs.getString(
                        "notes"
                )
        );

        return row;
    }

    // ============================================================
    // CALCULATE PERIOD RANGE
    //
    // All ranges are based on created_at.
    //
    // Day:
    //     today 00:00 → tomorrow 00:00
    //
    // Week:
    //     Monday 00:00 → next Monday 00:00
    //
    // Month:
    //     first day → first day of next month
    //
    // Year:
    //     January 1 → next January 1
    // ============================================================

    private PeriodRange calculatePeriodRange(
            String period
    ) {

        LocalDate today =
                LocalDate.now(
                        INDIA_ZONE
                );

        LocalDate startDate;

        switch (period) {

            case "day":

                startDate =
                        today;

                break;

            case "week":

                startDate =
                        today.with(
                                TemporalAdjusters
                                        .previousOrSame(
                                                DayOfWeek.MONDAY
                                        )
                        );

                break;

            case "year":

                startDate =
                        LocalDate.of(
                                today.getYear(),
                                Month.JANUARY,
                                1
                        );

                break;

            case "month":

            default:

                startDate =
                        today.withDayOfMonth(
                                1
                        );

                break;
        }

        LocalDateTime start =
                startDate.atStartOfDay();

        LocalDateTime end;

        switch (period) {

            case "day":

                end =
                        start.plusDays(
                                1
                        );

                break;

            case "week":

                end =
                        start.plusDays(
                                7
                        );

                break;

            case "year":

                end =
                        start.plusYears(
                                1
                        );

                break;

            case "month":

            default:

                end =
                        start.plusMonths(
                                1
                        );

                break;
        }

        return new PeriodRange(
                Timestamp.valueOf(
                        start
                ),
                Timestamp.valueOf(
                        end
                )
        );
    }

    // ============================================================
    // GRAPH GROUPING
    //
    // All expressions use created_at.
    // ============================================================

    private String getGroupingExpression(
            String period
    ) {

        return switch (period) {

            case "day" ->
                    "HOUR(p.created_at)";

            case "week" ->
                    "DATE(p.created_at)";

            case "year" ->
                    "MONTH(p.created_at)";

            case "month" ->
                    "DAY(p.created_at)";

            default ->
                    "DAY(p.created_at)";
        };
    }

    // ============================================================
    // GRAPH LABEL
    // ============================================================

    private String getLabelExpression(
            String period
    ) {

        return switch (period) {

            case "day" ->
                    "DATE_FORMAT("
                            + "p.created_at,"
                            + " '%H:00'"
                            + ")";

            case "week" ->
                    "DATE_FORMAT("
                            + "p.created_at,"
                            + " '%d %b'"
                            + ")";

            case "year" ->
                    "DATE_FORMAT("
                            + "p.created_at,"
                            + " '%b'"
                            + ")";

            case "month" ->
                    "DATE_FORMAT("
                            + "p.created_at,"
                            + " '%d %b'"
                            + ")";

            default ->
                    "DATE_FORMAT("
                            + "p.created_at,"
                            + " '%d %b'"
                            + ")";
        };
    }

    // ============================================================
    // NORMALIZE PERIOD
    // ============================================================

    private String normalizePeriod(
            String period
    ) {

        if (period == null ||
                period.trim().isEmpty()) {

            return "month";
        }

        return switch (
                period
                        .trim()
                        .toLowerCase()
        ) {

            case "all" ->
                    "all";

            case "day" ->
                    "day";

            case "week" ->
                    "week";

            case "month" ->
                    "month";

            case "year" ->
                    "year";

            default ->
                    throw new IllegalArgumentException(
                            "Invalid period. "
                                    + "Use all, day, week, month, or year."
                    );
        };
    }

    // ============================================================
    // INTERNAL PERIOD RANGE
    // ============================================================

    private record PeriodRange(
            Timestamp start,
            Timestamp end
    ) {
    }
}