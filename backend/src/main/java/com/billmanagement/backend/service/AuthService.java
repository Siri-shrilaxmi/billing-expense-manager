package com.billmanagement.backend.service;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.sql.Statement;
import java.util.Map;

@Service
public class AuthService {

    private final JdbcTemplate jdbcTemplate;
    private final JwtService jwtService;

    private final BCryptPasswordEncoder passwordEncoder =
            new BCryptPasswordEncoder();

    public AuthService(
            JdbcTemplate jdbcTemplate,
            JwtService jwtService
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.jwtService = jwtService;
    }

    // ============================================================
    // SIGN UP
    // ============================================================

    public Map<String, Object> signup(
            String name,
            String email,
            String password
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

        if (password == null ||
                password.length() < 6) {

            throw new IllegalArgumentException(
                    "Password must contain at least 6 characters."
            );
        }

        // --------------------------------------------------------
        // NORMALIZE INPUT
        // --------------------------------------------------------

        String normalizedName =
                name.trim();

        String normalizedEmail =
                email.trim().toLowerCase();

        // --------------------------------------------------------
        // HASH PASSWORD
        //
        // IMPORTANT:
        // The raw password is NEVER stored in the database.
        // --------------------------------------------------------

        String passwordHash =
                passwordEncoder.encode(password);

        System.out.println(
                "SIGNUP: Password hash generated. Length = "
                        + passwordHash.length()
        );

        try {

            // ----------------------------------------------------
            // INSERT USER
            // ----------------------------------------------------

            KeyHolder keyHolder =
                    new GeneratedKeyHolder();

            jdbcTemplate.update(
                    connection -> {

                        var statement =
                                connection.prepareStatement(
                                        """
                                        INSERT INTO `user`
                                        (
                                            name,
                                            email,
                                            password_hash
                                        )
                                        VALUES (?, ?, ?)
                                        """,
                                        Statement.RETURN_GENERATED_KEYS
                                );

                        statement.setString(
                                1,
                                normalizedName
                        );

                        statement.setString(
                                2,
                                normalizedEmail
                        );

                        statement.setString(
                                3,
                                passwordHash
                        );

                        return statement;
                    },
                    keyHolder
            );

            // ----------------------------------------------------
            // GET USER ID
            // ----------------------------------------------------

            if (keyHolder.getKey() == null) {

                throw new IllegalStateException(
                        "Could not obtain generated user ID."
                );
            }

            Long userId =
                    keyHolder
                            .getKey()
                            .longValue();

            // ----------------------------------------------------
            // GENERATE JWT
            // ----------------------------------------------------

            String token =
                    jwtService.generateToken(
                            userId,
                            normalizedEmail
                    );

            // ----------------------------------------------------
            // RESPONSE
            // ----------------------------------------------------

            return Map.of(
                    "success", true,
                    "user_id", userId,
                    "name", normalizedName,
                    "email", normalizedEmail,
                    "token", token
            );

        } catch (DuplicateKeyException e) {

            throw new IllegalArgumentException(
                    "An account with this email already exists."
            );
        }
    }

    // ============================================================
    // SIGN IN
    // ============================================================

    public Map<String, Object> signin(
            String email,
            String password
    ) {

        // --------------------------------------------------------
        // VALIDATION
        // --------------------------------------------------------

        if (email == null ||
                email.trim().isEmpty()) {

            throw new IllegalArgumentException(
                    "Email is required."
            );
        }

        if (password == null ||
                password.isEmpty()) {

            throw new IllegalArgumentException(
                    "Password is required."
            );
        }

        // --------------------------------------------------------
        // NORMALIZE EMAIL ONLY
        //
        // IMPORTANT:
        // We DO NOT modify the password.
        // BCrypt needs the exact password entered by the user.
        // --------------------------------------------------------

        String normalizedEmail =
                email.trim().toLowerCase();

        // --------------------------------------------------------
        // FIND USER
        // --------------------------------------------------------

        var users =
                jdbcTemplate.query(
                        """
                        SELECT
                            user_id,
                            name,
                            email,
                            password_hash
                        FROM `user`
                        WHERE email = ?
                        LIMIT 1
                        """,

                        (rs, rowNum) -> {

                            return new UserAuthData(
                                    rs.getLong("user_id"),
                                    rs.getString("name"),
                                    rs.getString("email"),
                                    rs.getString("password_hash")
                            );
                        },

                        normalizedEmail
                );

        // --------------------------------------------------------
        // USER NOT FOUND
        // --------------------------------------------------------

        if (users.isEmpty()) {

            System.out.println(
                    "SIGNIN: No user found for email = "
                            + normalizedEmail
            );

            throw new IllegalArgumentException(
                    "Invalid email or password."
            );
        }

        // --------------------------------------------------------
        // GET USER
        // --------------------------------------------------------

        UserAuthData user =
                users.get(0);

        // --------------------------------------------------------
        // CHECK STORED PASSWORD HASH
        // --------------------------------------------------------

        String storedHash =
                user.passwordHash();

        if (storedHash == null ||
                storedHash.trim().isEmpty()) {

            System.out.println(
                    "SIGNIN: password_hash is NULL or empty."
            );

            throw new IllegalArgumentException(
                    "Invalid email or password."
            );
        }

        System.out.println(
                "SIGNIN: User found. user_id = "
                        + user.userId()
        );

        System.out.println(
                "SIGNIN: Stored hash length = "
                        + storedHash.length()
        );

        // --------------------------------------------------------
        // IMPORTANT BCrypt CHECK
        //
        // BCrypt hashes normally have 60 characters and begin
        // with $2a$, $2b$ or another BCrypt-compatible prefix.
        // --------------------------------------------------------

        if (!storedHash.startsWith("$2")) {

            System.out.println(
                    "SIGNIN: Stored password is NOT a BCrypt hash."
            );

            throw new IllegalArgumentException(
                    "Invalid email or password."
            );
        }

        // --------------------------------------------------------
        // COMPARE RAW PASSWORD WITH HASH
        //
        // THIS IS CORRECT.
        //
        // password:
        //     raw password entered during sign in
        //
        // storedHash:
        //     BCrypt hash stored in MySQL
        //
        // BCrypt performs the comparison internally.
        // --------------------------------------------------------

        boolean passwordMatches =
                passwordEncoder.matches(
                        password,
                        storedHash
                );

        System.out.println(
                "SIGNIN: Password matches = "
                        + passwordMatches
        );

        if (!passwordMatches) {

            throw new IllegalArgumentException(
                    "Invalid email or password."
            );
        }

        // --------------------------------------------------------
        // GENERATE JWT
        // --------------------------------------------------------

        String token =
                jwtService.generateToken(
                        user.userId(),
                        normalizedEmail
                );

        // --------------------------------------------------------
        // RESPONSE
        // --------------------------------------------------------

        return Map.of(
                "success", true,
                "user_id", user.userId(),
                "name", user.name(),
                "email", normalizedEmail,
                "token", token
        );
    }

    // ============================================================
    // INTERNAL USER DATA
    // ============================================================

    private record UserAuthData(
            Long userId,
            String name,
            String email,
            String passwordHash
    ) {
    }
}