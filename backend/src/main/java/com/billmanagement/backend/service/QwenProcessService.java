package com.billmanagement.backend.service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;

@Service
public class QwenProcessService {

    private Process qwenProcess;

    private static final String PYTHON_PATH =
            "C:\\Users\\shril\\Documents\\GitHub\\personal_n_clg\\billing-expense-manager\\backend\\venv\\Scripts\\python.exe";

    private static final String QWEN_DIRECTORY =
            "C:\\Users\\shril\\Documents\\GitHub\\personal_n_clg\\billing-expense-manager\\backend\\qwen";

    private static final int QWEN_PORT = 8000;


    // ============================================================
    // START QWEN WHEN SPRING BOOT STARTS
    // ============================================================

    @PostConstruct
    public void startQwen() {

        try {

            System.out.println();
            System.out.println("========================================");
            System.out.println("Starting Qwen Python backend...");
            System.out.println("========================================");

            File python = new File(PYTHON_PATH);
            File qwenDirectory = new File(QWEN_DIRECTORY);

            if (!python.exists()) {

                throw new RuntimeException(
                        "Python executable not found: "
                                + PYTHON_PATH
                );
            }

            if (!qwenDirectory.exists()) {

                throw new RuntimeException(
                        "Qwen directory not found: "
                                + QWEN_DIRECTORY
                );
            }


            ProcessBuilder processBuilder =
                    new ProcessBuilder(
                            PYTHON_PATH,
                            "-m",
                            "uvicorn",
                            "qwen_server:app",
                            "--host",
                            "127.0.0.1",
                            "--port",
                            String.valueOf(QWEN_PORT)
                    );


            // Very important:
            // qwen_server.py imports qwen_service.py,
            // so Python must start inside backend/qwen.
            processBuilder.directory(qwenDirectory);


            // Show Qwen's terminal output in the
            // Spring Boot terminal.
            processBuilder.redirectErrorStream(true);


            qwenProcess = processBuilder.start();


            // Read Qwen output continuously.
            Thread outputThread = new Thread(() -> {

                try {

                    BufferedReader reader =
                            new BufferedReader(
                                    new InputStreamReader(
                                            qwenProcess.getInputStream()
                                    )
                            );

                    String line;

                    while ((line = reader.readLine()) != null) {

                        System.out.println(
                                "[QWEN] " + line
                        );
                    }

                } catch (Exception e) {

                    System.out.println(
                            "[QWEN] Output reader stopped."
                    );
                }

            });


            outputThread.setDaemon(true);
            outputThread.start();


            System.out.println();
            System.out.println(
                    "Qwen Python process started."
            );

            System.out.println(
                    "Qwen URL: http://127.0.0.1:"
                            + QWEN_PORT
            );

            System.out.println(
                    "Qwen is now loading the model..."
            );

            System.out.println();


        } catch (Exception e) {

            System.err.println();
            System.err.println(
                    "========================================"
            );
            System.err.println(
                    "FAILED TO START QWEN BACKEND"
            );
            System.err.println(
                    "========================================"
            );

            e.printStackTrace();

            throw new RuntimeException(
                    "Could not start Qwen backend.",
                    e
            );
        }
    }


    // ============================================================
    // STOP QWEN WHEN SPRING BOOT STOPS
    // ============================================================

    @PreDestroy
    public void stopQwen() {

        if (qwenProcess != null
                && qwenProcess.isAlive()) {

            System.out.println();
            System.out.println(
                    "Stopping Qwen Python backend..."
            );

            qwenProcess.destroy();

            System.out.println(
                    "Qwen backend stopped."
            );
        }
    }
}