package com.billmanagement.backend.service;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class AccountService {

    private final JdbcTemplate jdbcTemplate;

    private final BCryptPasswordEncoder passwordEncoder =
            new BCryptPasswordEncoder();

    public AccountService(
            JdbcTemplate jdbcTemplate
    ) {
        this.jdbcTemplate =
                jdbcTemplate;
    }

    // ============================================================
    // GET ACCOUNT
    // ============================================================

    public Map<String, Object> getAccount(
            Long userId
    ) {

        var rows =
                jdbcTemplate.query(
                        """
                        SELECT
                            user_id,
                            name,
                            email,
                            created_at,
                            updated_at
                        FROM `user`
                        WHERE user_id = ?
                        LIMIT 1
                        """,

                        (rs, rowNum) -> {

                            Map<String, Object> row =
                                    new LinkedHashMap<>();

                            row.put(
                                    "user_id",
                                    rs.getLong(
                                            "user_id"
                                    )
                            );

                            row.put(
                                    "name",
                                    rs.getString(
                                            "name"
                                    )
                            );

                            row.put(
                                    "email",
                                    rs.getString(
                                            "email"
                                    )
                            );

                            Timestamp createdAt =
                                    rs.getTimestamp(
                                            "created_at"
                                    );

                            Timestamp updatedAt =
                                    rs.getTimestamp(
                                            "updated_at"
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
                                    "updated_at",
                                    updatedAt == null
                                            ? null
                                            : updatedAt
                                                    .toLocalDateTime()
                                                    .toString()
                            );

                            return row;
                        },

                        userId
                );

        if (rows.isEmpty()) {

            throw new IllegalArgumentException(
                    "Account could not be found."
            );
        }

        return rows.get(0);
    }

    // ============================================================
    // UPDATE PROFILE
    // ============================================================

    public Map<String, Object> updateProfile(
            Long userId,
            String name,
            String email
    ) {

        // --------------------------------------------------------
        // VALIDATION
        // --------------------------------------------------------

        if (name == null ||
                name.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Name is required."
            );
        }

        if (email == null ||
                email.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Email is required."
            );
        }

        String normalizedName =
                name.trim();

        String normalizedEmail =
                email.trim().toLowerCase();

        // --------------------------------------------------------
        // CHECK EMAIL DUPLICATE
        // --------------------------------------------------------

        Integer existingCount =
                jdbcTemplate.queryForObject(
                        """
                        SELECT COUNT(*)
                        FROM `user`
                        WHERE email = ?
                          AND user_id <> ?
                        """,

                        Integer.class,

                        normalizedEmail,
                        userId
                );

        if (existingCount != null &&
                existingCount > 0) {

            throw new IllegalArgumentException(
                    "An account with this email already exists."
            );
        }

        // --------------------------------------------------------
        // UPDATE USER
        // --------------------------------------------------------

        try {

            int updated =
                    jdbcTemplate.update(
                            """
                            UPDATE `user`
                            SET
                                name = ?,
                                email = ?,
                                updated_at = CURRENT_TIMESTAMP
                            WHERE user_id = ?
                            """,

                            normalizedName,
                            normalizedEmail,
                            userId
                    );

            if (updated == 0) {

                throw new IllegalArgumentException(
                        "Account could not be updated."
                );
            }

        } catch (DuplicateKeyException e) {

            throw new IllegalArgumentException(
                    "An account with this email already exists."
            );
        }

        return getAccount(
                userId
        );
    }

    // ============================================================
    // CHANGE PASSWORD
    // ============================================================

    public void changePassword(
            Long userId,
            String currentPassword,
            String newPassword
    ) {

        // --------------------------------------------------------
        // VALIDATION
        // --------------------------------------------------------

        if (currentPassword == null ||
                currentPassword.isEmpty()) {

            throw new IllegalArgumentException(
                    "Current password is required."
            );
        }

        if (newPassword == null ||
                newPassword.length() < 6) {

            throw new IllegalArgumentException(
                    "New password must contain at least 6 characters."
            );
        }

        if (currentPassword.equals(
                newPassword
        )) {

            throw new IllegalArgumentException(
                    "New password must be different from the current password."
            );
        }

        // --------------------------------------------------------
        // GET STORED PASSWORD HASH
        // --------------------------------------------------------

        var hashes =
                jdbcTemplate.query(
                        """
                        SELECT
                            password_hash
                        FROM `user`
                        WHERE user_id = ?
                        LIMIT 1
                        """,

                        (rs, rowNum) ->
                                rs.getString(
                                        "password_hash"
                                ),

                        userId
                );

        if (hashes.isEmpty()) {

            throw new IllegalArgumentException(
                    "Account could not be found."
            );
        }

        String storedHash =
                hashes.get(0);

        if (storedHash == null ||
                storedHash.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Stored password is invalid."
            );
        }

        // --------------------------------------------------------
        // VERIFY CURRENT PASSWORD
        // --------------------------------------------------------

        boolean matches =
                passwordEncoder.matches(
                        currentPassword,
                        storedHash
                );

        if (!matches) {

            throw new IllegalArgumentException(
                    "Current password is incorrect."
            );
        }

        // --------------------------------------------------------
        // HASH NEW PASSWORD
        // --------------------------------------------------------

        String newHash =
                passwordEncoder.encode(
                        newPassword
                );

        // --------------------------------------------------------
        // SAVE NEW PASSWORD
        // --------------------------------------------------------

        int updated =
                jdbcTemplate.update(
                        """
                        UPDATE `user`
                        SET
                            password_hash = ?,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE user_id = ?
                        """,

                        newHash,
                        userId
                );

        if (updated == 0) {

            throw new IllegalArgumentException(
                    "Password could not be updated."
            );
        }
    }
}