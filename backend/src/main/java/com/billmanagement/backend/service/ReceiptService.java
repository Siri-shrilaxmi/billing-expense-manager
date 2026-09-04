package com.billmanagement.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@Service
public class ReceiptService {

    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public ReceiptService(
            JdbcTemplate jdbcTemplate,
            ObjectMapper objectMapper
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
    }

    // ============================================================
    // SAVE RECEIPT
    // ============================================================

    @Transactional
    public Map<String, Object> saveReceipt(
            Long userId,
            Map<String, Object> data
    ) throws Exception {

        String merchant =
                cleanString(
                        data.get("merchant")
                );

        if (merchant == null) {
            throw new IllegalArgumentException(
                    "Merchant is required."
            );
        }

        BigDecimal amount =
                parseAmount(
                        data.get("amount")
                );

        if (amount == null) {
            throw new IllegalArgumentException(
                    "Amount is required."
            );
        }

        String currency =
                cleanString(
                        data.get("currency")
                );

        if (currency == null) {
            currency = "INR";
        }

        String notes =
                cleanString(
                        data.get("notes")
                );

        String source =
                cleanString(
                        data.get("source")
                );

        if (source == null) {
            source = "file_upload";
        }

        // This is the transaction time printed on the bill.
        // It is allowed to be NULL.
        LocalDateTime paymentTime =
                parseDateTime(
                        data.get("payment_time")
                );

        BigDecimal ocrConfidence =
                parseDecimal(
                        data.get(
                                "generation_confidence"
                        )
                );

        String normalizedName =
                normalizeReceiverName(
                        merchant
                );

        Long receiverId =
                getOrCreateReceiver(
                        merchant,
                        normalizedName
                );

        Long paymentId =
                insertPayment(
                        userId,
                        receiverId,
                        amount,
                        currency,
                        paymentTime,
                        source,
                        notes
                );

        String ocrText = null;

        Object rawQwen =
                data.get("qwen_result");

        if (rawQwen != null) {
            ocrText =
                    objectMapper.writeValueAsString(
                            rawQwen
                    );
        }

        Long receiptId =
                insertReceipt(
                        paymentId,
                        ocrText,
                        ocrConfidence
                );

        return Map.of(
                "success", true,
                "receipt_id", receiptId,
                "payment_id", paymentId,
                "receiver_id", receiverId
        );
    }

    // ============================================================
    // RECEIVER
    // ============================================================

    private Long getOrCreateReceiver(
            String name,
            String normalizedName
    ) {

        jdbcTemplate.update(
                """
                INSERT INTO receiver
                (
                    name,
                    normalized_name
                )
                VALUES (?, ?)
                ON DUPLICATE KEY UPDATE
                    receiver_id =
                    LAST_INSERT_ID(receiver_id)
                """,
                name,
                normalizedName
        );

        return jdbcTemplate.queryForObject(
                "SELECT LAST_INSERT_ID()",
                Long.class
        );
    }

    // ============================================================
    // PAYMENT
    //
    // created_at is deliberately NOT inserted here.
    //
    // MySQL fills it automatically through:
    //
    // DEFAULT CURRENT_TIMESTAMP
    // ============================================================

    private Long insertPayment(
            Long userId,
            Long receiverId,
            BigDecimal amount,
            String currency,
            LocalDateTime paymentTime,
            String source,
            String notes
    ) {

        var keyHolder =
                new org.springframework.jdbc.support.GeneratedKeyHolder();

        jdbcTemplate.update(
                connection -> {

                    var statement =
                            connection.prepareStatement(
                                    """
                                    INSERT INTO payment
                                    (
                                        user_id,
                                        receiver_id,
                                        amount,
                                        currency,
                                        payment_time,
                                        source,
                                        notes
                                    )
                                    VALUES (?, ?, ?, ?, ?, ?, ?)
                                    """,
                                    java.sql.Statement.RETURN_GENERATED_KEYS
                            );

                    statement.setLong(
                            1,
                            userId
                    );

                    statement.setLong(
                            2,
                            receiverId
                    );

                    statement.setBigDecimal(
                            3,
                            amount
                    );

                    statement.setString(
                            4,
                            currency
                    );

                    if (paymentTime == null) {

                        statement.setTimestamp(
                                5,
                                null
                        );

                    } else {

                        statement.setTimestamp(
                                5,
                                Timestamp.valueOf(
                                        paymentTime
                                )
                        );
                    }

                    statement.setString(
                            6,
                            source
                    );

                    statement.setString(
                            7,
                            notes
                    );

                    return statement;
                },
                keyHolder
        );

        if (keyHolder.getKey() == null) {
            throw new IllegalStateException(
                    "Could not obtain generated payment ID."
            );
        }

        return keyHolder
                .getKey()
                .longValue();
    }

    // ============================================================
    // RECEIPT
    // ============================================================

    private Long insertReceipt(
            Long paymentId,
            String ocrText,
            BigDecimal ocrConfidence
    ) {

        var keyHolder =
                new org.springframework.jdbc.support.GeneratedKeyHolder();

        jdbcTemplate.update(
                connection -> {

                    var statement =
                            connection.prepareStatement(
                                    """
                                    INSERT INTO receipt
                                    (
                                        payment_id,
                                        image_path,
                                        ocr_text,
                                        ocr_confidence
                                    )
                                    VALUES (?, ?, ?, ?)
                                    """,
                                    java.sql.Statement.RETURN_GENERATED_KEYS
                            );

                    statement.setLong(
                            1,
                            paymentId
                    );

                    statement.setString(
                            2,
                            null
                    );

                    statement.setString(
                            3,
                            ocrText
                    );

                    statement.setBigDecimal(
                            4,
                            ocrConfidence
                    );

                    return statement;
                },
                keyHolder
        );

        if (keyHolder.getKey() == null) {
            throw new IllegalStateException(
                    "Could not obtain generated receipt ID."
            );
        }

        return keyHolder
                .getKey()
                .longValue();
    }

    // ============================================================
    // NORMALIZATION
    // ============================================================

    private String normalizeReceiverName(
            String value
    ) {

        String normalized =
                value
                        .toLowerCase()
                        .trim();

        normalized =
                normalized.replace(
                        "&",
                        " and "
                );

        normalized =
                normalized.replaceAll(
                        "[^a-z0-9 ]",
                        " "
                );

        normalized =
                normalized.replaceAll(
                        "\\s+",
                        " "
                );

        return normalized.trim();
    }

    // ============================================================
    // STRING
    // ============================================================

    private String cleanString(
            Object value
    ) {

        if (value == null) {
            return null;
        }

        String text =
                value.toString().trim();

        if (text.isEmpty()) {
            return null;
        }

        return text;
    }

    // ============================================================
    // AMOUNT
    // ============================================================

    private BigDecimal parseAmount(
            Object value
    ) {

        if (value == null) {
            return null;
        }

        try {

            String text =
                    value.toString()
                            .replace(",", "")
                            .trim();

            if (text.isEmpty()) {
                return null;
            }

            return new BigDecimal(
                    text
            );

        } catch (Exception e) {

            throw new IllegalArgumentException(
                    "Invalid amount."
            );
        }
    }

    // ============================================================
    // DECIMAL
    // ============================================================

    private BigDecimal parseDecimal(
            Object value
    ) {

        if (value == null) {
            return null;
        }

        try {

            return new BigDecimal(
                    value.toString()
            );

        } catch (Exception e) {

            return null;
        }
    }

    // ============================================================
    // DATE/TIME
    // ============================================================

    private LocalDateTime parseDateTime(
            Object value
    ) {

        if (value == null) {
            return null;
        }

        String text =
                value.toString().trim();

        if (text.isEmpty()) {
            return null;
        }

        String[] formats = {
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd'T'HH:mm",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd HH:mm",
                "dd/MM/yyyy HH:mm:ss",
                "dd/MM/yyyy HH:mm"
        };

        for (String format : formats) {

            try {

                return LocalDateTime.parse(
                        text,
                        DateTimeFormatter.ofPattern(
                                format
                        )
                );

            } catch (Exception ignored) {
            }
        }

        throw new IllegalArgumentException(
                "Invalid date/time format. "
                        + "Use yyyy-MM-dd HH:mm."
        );
    }
}