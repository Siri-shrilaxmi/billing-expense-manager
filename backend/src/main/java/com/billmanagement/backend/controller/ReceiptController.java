package com.billmanagement.backend.controller;

import com.billmanagement.backend.service.ReceiptService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/receipt")
@CrossOrigin(origins = "*")
public class ReceiptController {

    private final ReceiptService receiptService;

    public ReceiptController(
            ReceiptService receiptService
    ) {
        this.receiptService = receiptService;
    }

    // ============================================================
    // SAVE RECEIPT
    // ============================================================

    @PostMapping("/save")
    public ResponseEntity<?> saveReceipt(
            @RequestAttribute("userId") Long userId,
            @RequestBody Map<String, Object> data
    ) {

        try {

            Map<String, Object> result =
                    receiptService.saveReceipt(
                            userId,
                            data
                    );

            return ResponseEntity.ok(
                    result
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
                                    "success",
                                    false,

                                    "error",
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

                                    "error",
                                    "Failed to save receipt",

                                    "message",
                                    e.getMessage() != null
                                            ? e.getMessage()
                                            : "Unknown server error"
                            )
                    );
        }
    }
}