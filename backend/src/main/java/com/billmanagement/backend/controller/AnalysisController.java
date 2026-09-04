package com.billmanagement.backend.controller;

import com.billmanagement.backend.service.AnalysisService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/analysis")
@CrossOrigin(origins = "*")
public class AnalysisController {

    private final AnalysisService analysisService;

    public AnalysisController(
            AnalysisService analysisService
    ) {
        this.analysisService =
                analysisService;
    }

    // ============================================================
    // RECENT
    // ============================================================

    @GetMapping("/recent")
    public ResponseEntity<?> recent(
            @RequestAttribute("userId")
            Long userId
    ) {

        try {

            return ResponseEntity.ok(
                    analysisService.getRecentReceipts(
                            userId
                    )
            );

        } catch (Exception e) {

            e.printStackTrace();

            return ResponseEntity
                    .internalServerError()
                    .body(
                            Map.of(
                                    "error",
                                    "Could not load recent receipts.",
                                    "message",
                                    e.getMessage()
                            )
                    );
        }
    }

    // ============================================================
    // FULL HISTORY
    // ============================================================

    @GetMapping("/history")
    public ResponseEntity<?> history(
            @RequestAttribute("userId")
            Long userId,

            @RequestParam(
                    defaultValue = "all"
            )
            String period,

            @RequestParam(
                    defaultValue = "INR"
            )
            String currency
    ) {

        try {

            return ResponseEntity.ok(
                    analysisService.getHistory(
                            userId,
                            period,
                            currency
                    )
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
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
                                    "error",
                                    "Could not load receipt history.",
                                    "message",
                                    e.getMessage()
                            )
                    );
        }
    }

    // ============================================================
    // SPENDING GRAPH
    // ============================================================

    @GetMapping("/spending")
    public ResponseEntity<?> spending(
            @RequestAttribute("userId")
            Long userId,

            @RequestParam(
                    defaultValue = "month"
            )
            String period,

            @RequestParam(
                    defaultValue = "INR"
            )
            String currency
    ) {

        try {

            return ResponseEntity.ok(
                    analysisService.getAnalytics(
                            userId,
                            period,
                            currency
                    )
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
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
                                    "error",
                                    "Could not load spending analysis.",
                                    "message",
                                    e.getMessage()
                            )
                    );
        }
    }

    // ============================================================
    // MERCHANT SUMMARY
    // ============================================================

    @GetMapping("/merchants")
    public ResponseEntity<?> merchants(
            @RequestAttribute("userId")
            Long userId,

            @RequestParam(
                    defaultValue = "month"
            )
            String period,

            @RequestParam(
                    defaultValue = "INR"
            )
            String currency
    ) {

        try {

            return ResponseEntity.ok(
                    analysisService.getMerchantSummary(
                            userId,
                            period,
                            currency
                    )
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
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
                                    "error",
                                    "Could not load merchant analysis.",
                                    "message",
                                    e.getMessage()
                            )
                    );
        }
    }

    // ============================================================
    // MERCHANT DETAILS
    // ============================================================

    @GetMapping(
            "/merchants/{receiverId}"
    )
    public ResponseEntity<?> merchantHistory(
            @RequestAttribute("userId")
            Long userId,

            @PathVariable
            Long receiverId,

            @RequestParam(
                    defaultValue = "all"
            )
            String period,

            @RequestParam(
                    defaultValue = "INR"
            )
            String currency
    ) {

        try {

            return ResponseEntity.ok(
                    analysisService.getMerchantHistory(
                            userId,
                            receiverId,
                            period,
                            currency
                    )
            );

        } catch (IllegalArgumentException e) {

            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
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
                                    "error",
                                    "Could not load merchant history.",
                                    "message",
                                    e.getMessage()
                            )
                    );
        }
    }
}