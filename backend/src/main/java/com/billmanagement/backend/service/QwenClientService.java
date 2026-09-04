package com.billmanagement.backend.service;

import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Service
public class QwenClientService {

    private static final String QWEN_URL =
            "http://127.0.0.1:8000/analyze";

    private final RestTemplate restTemplate;

    public QwenClientService() {

        this.restTemplate = new RestTemplate();

    }

    // ============================================================
    // SEND IMAGE TO QWEN
    // ============================================================

    public Map<String, Object> analyzeImage(
            byte[] imageBytes
    ) {

        if (imageBytes == null || imageBytes.length == 0) {

            throw new IllegalArgumentException(
                    "Image is empty."
            );
        }

        HttpHeaders headers = new HttpHeaders();

        headers.setContentType(
                MediaType.APPLICATION_OCTET_STREAM
        );

        HttpEntity<byte[]> request =
                new HttpEntity<>(
                        imageBytes,
                        headers
                );

        ResponseEntity<Map> response =
                restTemplate.exchange(
                        QWEN_URL,
                        HttpMethod.POST,
                        request,
                        Map.class
                );

        if (!response.getStatusCode().is2xxSuccessful()) {

            throw new RuntimeException(
                    "Qwen server returned HTTP "
                            + response.getStatusCode()
            );
        }

        if (response.getBody() == null) {

            throw new RuntimeException(
                    "Qwen server returned an empty response."
            );
        }

        return response.getBody();
    }
}