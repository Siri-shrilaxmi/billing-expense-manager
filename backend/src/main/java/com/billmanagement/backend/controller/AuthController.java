package com.billmanagement.backend.controller;

import com.billmanagement.backend.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(
            AuthService authService
    ) {
        this.authService = authService;
    }

    // ============================================================
    // SIGN UP
    // ============================================================

    @PostMapping("/signup")
    public ResponseEntity<?> signup(
            @RequestBody Map<String, String> request
    ) {

        try {

            String name =
                    request.get("name");

            String email =
                    request.get("email");

            String password =
                    request.get("password");

            return ResponseEntity.ok(
                    authService.signup(
                            name,
                            email,
                            password
                    )
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
                                    "success", false,
                                    "message", e.getMessage()
                            )
                    );
        }
    }

    // ============================================================
    // SIGN IN
    // ============================================================

    @PostMapping("/signin")
    public ResponseEntity<?> signin(
            @RequestBody Map<String, String> request
    ) {

        try {

            String email =
                    request.get("email");

            String password =
                    request.get("password");

            return ResponseEntity.ok(
                    authService.signin(
                            email,
                            password
                    )
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
                                    "success", false,
                                    "message", e.getMessage()
                            )
                    );
        }
    }
}