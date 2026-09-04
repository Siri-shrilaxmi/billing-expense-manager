package com.billmanagement.backend.controller;

import com.billmanagement.backend.service.QwenClientService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/image")
@CrossOrigin(origins = "*")
public class ImageController {

    private final QwenClientService qwenClientService;

    public ImageController(
            QwenClientService qwenClientService
    ) {
        this.qwenClientService = qwenClientService;
    }

    @PostMapping(
            value = "/analyze",
            consumes = MediaType.APPLICATION_OCTET_STREAM_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public ResponseEntity<Map<String, Object>> analyzeImage(
            @RequestBody byte[] imageBytes
    ) {

        System.out.println();
        System.out.println("========================================");
        System.out.println("Spring Boot received image");
        System.out.println(
                "Image size: " + imageBytes.length + " bytes"
        );
        System.out.println("Sending image to Qwen...");
        System.out.println("========================================");

        try {

            Map<String, Object> result =
                    qwenClientService.analyzeImage(imageBytes);

            System.out.println();
            System.out.println(
                    "Image successfully analyzed by Qwen."
            );

            return ResponseEntity.ok(result);

        } catch (Exception e) {

            System.err.println();
            System.err.println(
                    "========================================"
            );
            System.err.println(
                    "QWEN ANALYSIS FAILED"
            );
            System.err.println(
                    "========================================"
            );

            e.printStackTrace();

            return ResponseEntity.internalServerError()
                    .body(
                            Map.of(
                                    "error",
                                    "Qwen analysis failed",
                                    "message",
                                    e.getMessage() == null
                                            ? "Unknown error"
                                            : e.getMessage()
                            )
                    );
        }
    }
}