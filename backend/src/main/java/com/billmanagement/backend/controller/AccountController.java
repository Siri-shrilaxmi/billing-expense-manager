package com.billmanagement.backend.controller;

import com.billmanagement.backend.service.AccountService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/account")
@CrossOrigin(origins = "*")
public class AccountController {

    private final AccountService accountService;

    public AccountController(
            AccountService accountService
    ) {
        this.accountService =
                accountService;
    }

    // ============================================================
    // GET ACCOUNT
    // ============================================================

    @GetMapping
    public ResponseEntity<?> getAccount(
            @RequestAttribute("userId")
            Long userId
    ) {

        try {

            return ResponseEntity.ok(
                    accountService.getAccount(
                            userId
                    )
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
                                    "success",
                                    false,
                                    "message",
                                    e.getMessage()
                            )
                    );

        } catch (Exception e) {

            e.printStackTrace();

            return ResponseEntity
                    .internalServerError()
                    .body(
                            Map.of(
                                    "success",
                                    false,
                                    "message",
                                    "Could not load account information."
                            )
                    );
        }
    }

    // ============================================================
    // UPDATE PROFILE
    // ============================================================

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(
            @RequestAttribute("userId")
            Long userId,

            @RequestBody
            Map<String, String> request
    ) {

        try {

            String name =
                    request.get("name");

            String email =
                    request.get("email");

            return ResponseEntity.ok(
                    accountService.updateProfile(
                            userId,
                            name,
                            email
                    )
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
                                    "success",
                                    false,
                                    "message",
                                    e.getMessage()
                            )
                    );

        } catch (Exception e) {

            e.printStackTrace();

            return ResponseEntity
                    .internalServerError()
                    .body(
                            Map.of(
                                    "success",
                                    false,
                                    "message",
                                    "Could not update profile."
                            )
                    );
        }
    }

    // ============================================================
    // CHANGE PASSWORD
    // ============================================================

    @PutMapping("/password")
    public ResponseEntity<?> changePassword(
            @RequestAttribute("userId")
            Long userId,

            @RequestBody
            Map<String, String> request
    ) {

        try {

            String currentPassword =
                    request.get(
                            "current_password"
                    );

            String newPassword =
                    request.get(
                            "new_password"
                    );

            accountService.changePassword(
                    userId,
                    currentPassword,
                    newPassword
            );

            return ResponseEntity.ok(
                    Map.of(
                            "success",
                            true,

                            "message",
                            "Password updated successfully."
                    )
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
                                    "success",
                                    false,
                                    "message",
                                    e.getMessage()
                            )
                    );

        } catch (Exception e) {

            e.printStackTrace();

            return ResponseEntity
                    .internalServerError()
                    .body(
                            Map.of(
                                    "success",
                                    false,
                                    "message",
                                    "Could not update password."
                            )
                    );
        }
    }
}