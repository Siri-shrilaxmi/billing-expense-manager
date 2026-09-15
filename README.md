# Billing Expense Manager

A full-stack receipt and expense management application that helps users capture, extract, review, store, and analyze billing information.

The application combines a **Flutter frontend**, **Spring Boot backend**, **MySQL database**, **OCR processing**, and **Qwen-based AI processing** to reduce the amount of manual data entry required when recording expenses.

---

## Features

### Receipt Scanning

- Capture receipts using the device camera.
- Upload receipt images from the device.
- Preprocess receipt images before analysis.
- Sanitize images before sending them for processing.
- Extract receipt information using OCR and AI.
- Review extracted information before saving.
- Edit extracted fields when necessary.
- Display processing status and processing time.

### Receipt Data

The application works with receipt information including:

- Merchant / receiver
- Amount
- Currency
- Payment date and time
- Notes
- Receipt source
- OCR / AI result
- Generation confidence
- Scan / save timestamp

### Authentication

- User registration
- User sign-in
- BCrypt password hashing
- JWT-based authentication
- Protected API endpoints
- Session-expiration handling on the Flutter client

### Expense History

Users can view saved transactions and filter them by:

- All time
- Day
- Week
- Month
- Year
- Currency

The application keeps the **scan/save time** separate from the **original payment time** when available.

### Spending Analysis

The analysis section provides:

- Recent receipts
- Complete receipt history
- Spending charts
- Spending totals
- Transaction counts
- Merchant / receiver summaries
- Merchant transaction history
- Period-based filtering
- Currency-based filtering

Repeated transactions are retained rather than being silently deduplicated, allowing the application to represent the user's actual payment history.

### Theme Support

The Flutter application supports:

- System theme
- Light theme
- Dark theme

### Cross-Platform Flutter Structure

The Flutter project contains platform targets for:

- Windows
- Web
- Android
- iOS
- Linux
- macOS

The primary development environment is currently Windows.

---

# Technology Stack

## Frontend

- Flutter
- Dart
- Material 3
- HTTP
- Camera integration
- File picker
- Responsive Flutter UI

## Backend

- Java
- Spring Boot
- Spring MVC
- Spring JDBC
- MySQL Connector
- BCrypt
- JWT

## OCR / AI

- Python
- OCR processing
- Qwen-based AI processing
- Local Python services for receipt processing

## Database

- MySQL

---

# Architecture

```text
┌───────────────────────────────┐
│        Flutter Frontend       │
│                               │
│ Sign In / Sign Up             │
│ Source Selection              │
│ Camera / File Upload          │
│ Receipt Review                │
│ History                       │
│ Analysis                      │
│ Settings                      │
└───────────────┬───────────────┘
                │
                │ HTTP + JWT
                ▼
┌───────────────────────────────┐
│       Spring Boot Backend     │
│                               │
│ Authentication                │
│ Receipt APIs                  │
│ Image Analysis APIs           │
│ History APIs                  │
│ Analysis APIs                 │
└───────┬───────────────┬───────┘
        │               │
        │               │
        ▼               ▼
┌───────────────┐ ┌────────────────────┐
│     MySQL     │ │ OCR / Qwen Services│
│               │ │                    │
│ Users         │ │ OCR extraction     │
│ Receivers     │ │ AI processing      │
│ Payments      │ │ Receipt parsing    │
└───────────────┘ └────────────────────┘
```

---

# Project Structure

```text
billing-expense-manager/
│
├── README.md
├── .gitignore
│
├── backend/
│   │
│   ├── ocr/
│   │   └── ocr.py
│   │
│   ├── qwen/
│   │   ├── qwen_api.py
│   │   ├── qwen_server.py
│   │   └── qwen_service.py
│   │
│   ├── service/
│   │   └── QwenProcessService.java
│   │
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/billmanagement/backend/
│   │   │   │   ├── config/
│   │   │   │   ├── controller/
│   │   │   │   ├── layout/
│   │   │   │   └── service/
│   │   │   │
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   │
│   │   └── test/
│   │
│   ├── pom.xml
│   ├── mvnw
│   └── mvnw.cmd
│
└── frontend/
    │
    ├── lib/
    │   ├── screens/
    │   ├── services/
    │   ├── theme/
    │   └── main.dart
    │
    ├── android/
    ├── ios/
    ├── linux/
    ├── macos/
    ├── web/
    ├── windows/
    │
    ├── pubspec.yaml
    └── pubspec.lock
```

---

# Important Frontend Screens

The main Flutter screens are located in:

```text
frontend/lib/screens/
```

### Authentication

```text
sign_in_screen.dart
sign_up_screen.dart
```

### Receipt Workflow

```text
source_selection_screen.dart
camera_scanner_screen.dart
scanner_screen.dart
```

### Expense Analysis

```text
analysis_screen.dart
receipt_history_screen.dart
merchant_history_screen.dart
```

### Application Settings

```text
settings_screen.dart
```

---

# Backend Structure

The Spring Boot application is organized into configuration, controllers, and services.

```text
backend/src/main/java/com/billmanagement/backend/
│
├── config/
│   ├── AuthInterceptor.java
│   ├── CorsConfig.java
│   └── WebConfig.java
│
├── controller/
│   ├── AccountController.java
│   ├── AnalysisController.java
│   ├── AuthController.java
│   ├── ImageController.java
│   └── ReceiptController.java
│
├── layout/
│   └── OCRWord.java
│
└── service/
    ├── AccountService.java
    ├── AnalysisService.java
    ├── AuthService.java
    ├── JwtService.java
    ├── QwenClientService.java
    ├── QwenProcessService.java
    └── ReceiptService.java
```

---

# API Overview

## Authentication

```http
POST /api/auth/signup
POST /api/auth/signin
```

These endpoints are public.

---

## Receipt Image Processing

```http
POST /api/image/analyze
```

Analyzes a receipt image using the OCR / AI processing pipeline.

---

## Save Receipt

```http
POST /api/receipt/save
```

Stores the reviewed receipt and transaction information.

---

## Receipt Analysis

```http
GET /api/analysis/recent
GET /api/analysis/history
GET /api/analysis/spending
GET /api/analysis/merchants
GET /api/analysis/merchants/{receiverId}
```

These endpoints require authentication.

---

# Authentication

The application uses JWT authentication for protected APIs.

After successful sign-in, the Flutter application stores the authentication token and sends it with protected requests.

Example:

```http
Authorization: Bearer <JWT_TOKEN>
```

The Spring Boot `AuthInterceptor` validates the token before allowing access to protected resources.

The authenticated user's ID is extracted from the JWT and used to restrict access to that user's data.

---

# Database

The application uses MySQL.

The main database is:

```text
bill_management_platform
```

Create the database with:

```sql
CREATE DATABASE bill_management_platform;
```

The backend uses Spring JDBC to communicate with MySQL.

---

# Configuration and Secrets

Sensitive values must not be committed to Git.

The backend configuration uses environment variables:

```properties
spring.datasource.password=${DB_PASSWORD}
jwt.secret=${JWT_SECRET}
```

Set these values in your local development environment.

### Windows PowerShell

```powershell
$env:DB_PASSWORD="your_mysql_password"
$env:JWT_SECRET="your_long_random_jwt_secret"
```

Then start the backend from the same terminal session.

> Never commit real database passwords, JWT secrets, API keys, model credentials, or other private credentials to the repository.

---

# Requirements

Install the following before running the complete project.

## Required

- Git
- Flutter SDK
- Dart SDK (included with Flutter)
- Java JDK
- MySQL Server
- Python
- Required Python packages for the OCR / Qwen services

## Windows

For native Windows builds, install the Flutter Windows development requirements, including the Visual Studio C++ desktop development toolchain and Windows SDK.

---

# Setup

## 1. Clone the repository

```bash
git clone <your-repository-url>
cd billing-expense-manager
```

---

## 2. Create the MySQL database

Open MySQL Workbench or a MySQL terminal and run:

```sql
CREATE DATABASE bill_management_platform;
```

---

## 3. Configure backend environment variables

In PowerShell:

```powershell
$env:DB_PASSWORD="your_mysql_password"
$env:JWT_SECRET="your_long_random_jwt_secret"
```

Use your own local values.

---

## 4. Install backend dependencies

Move into the backend directory:

```powershell
cd backend
```

Run:

```powershell
.\mvnw.cmd clean install
```

---

## 5. Start the Spring Boot backend

From the `backend` directory:

```powershell
.\mvnw.cmd spring-boot:run
```

The backend is configured to run on:

```text
http://localhost:8080
```

---

# Starting the OCR / Qwen Services

The project contains Python components for receipt processing:

```text
backend/ocr/ocr.py
backend/qwen/qwen_api.py
backend/qwen/qwen_server.py
backend/qwen/qwen_service.py
```

Install the Python dependencies required by the current implementation before starting these services.

Start the services according to the Python scripts and local model configuration used by the project.

The Qwen service is used by the backend during AI-assisted receipt processing.

---

# Starting the Flutter Frontend

Move into the frontend directory:

```powershell
cd frontend
```

Install Flutter dependencies:

```powershell
flutter pub get
```

---

## Run on Windows

```powershell
flutter run -d windows
```

---

## Run on Chrome

```powershell
flutter run -d chrome
```

---

# Receipt Processing Workflow

The complete receipt workflow is:

```text
User
  │
  ▼
Choose Source
  │
  ├── Camera
  │
  └── File Upload
  │
  ▼
Receipt Image
  │
  ▼
Image Preprocessing
  │
  ▼
Image Sanitization
  │
  ▼
OCR
  │
  ▼
Qwen AI Processing
  │
  ▼
Extracted Receipt Data
  │
  ▼
User Reviews / Edits
  │
  ▼
Save Receipt
  │
  ▼
MySQL
  │
  ▼
History + Spending Analysis
```

---

# Receipt Dates

The application distinguishes between the time the receipt was scanned/saved and the original payment time.

### `created_at`

Represents when the transaction was saved/processed by the application.

### `payment_time`

Represents the payment date/time extracted from the receipt when available.

This distinction allows spending analysis and history to use the scan/save timeline while still preserving the original payment information.

---

# Spending Analysis

The analysis system supports the following periods:

```text
All
Day
Week
Month
Year
```

It also supports currency filtering.

The spending graph is based on the receipt scan/save timestamp.

The merchant/receiver analysis aggregates transactions for each receiver and keeps repeated payments as separate transactions when calculating totals and counts.

---

# Security

The project includes:

- BCrypt password hashing
- JWT authentication
- Protected API endpoints
- User-specific database queries
- Authentication interceptors
- Environment-based sensitive configuration
- Git ignore rules for local and sensitive files

For production use, credentials, secrets, database access, and model configuration should be managed using an appropriate secure deployment mechanism rather than local development values.

---

# Testing

## Backend

Backend tests are located under:

```text
backend/src/test/
```

Run them with:

```powershell
cd backend
.\mvnw.cmd test
```

---

## Flutter

Flutter tests are located under:

```text
frontend/test/
```

Run them with:

```powershell
cd frontend
flutter test
```

---

# Building

## Flutter Web

```powershell
cd frontend
flutter build web
```

The generated web build is placed in Flutter's build output directory.

---

## Windows Desktop

```powershell
cd frontend
flutter build windows
```

Native Windows packaging requires a correctly configured Windows desktop build toolchain.

---

# Git Development

Before committing changes:

```powershell
git status
```

Stage files:

```powershell
git add .
```

Review staged changes:

```powershell
git diff --cached
```

Commit:

```powershell
git commit -m "Describe your changes"
```

Push:

```powershell
git push origin main
```

Do not commit:

- passwords
- JWT secrets
- API keys
- local model files
- generated build output
- temporary uploaded images
- local environment configuration

---

# Current Project Status

The project currently contains the main building blocks of a complete billing and expense management system:

- Flutter application
- Spring Boot backend
- MySQL integration
- User authentication
- JWT security
- Receipt image upload
- Camera receipt capture
- OCR processing
- Qwen AI processing
- Receipt review and editing
- Receipt persistence
- Receipt history
- Merchant / receiver analysis
- Spending analysis
- Theme selection
- Windows and web Flutter targets

The project is still under active development, and additional production-oriented improvements are planned.

---

# Future Improvements

Possible future enhancements include:

- Improved receipt extraction accuracy
- Expense categories
- Budget tracking
- Monthly budget alerts
- Advanced spending charts
- Export to CSV / Excel / PDF
- Cloud synchronization
- Multi-device synchronization
- Improved account management
- Notification and reminder support
- Automated integration tests
- Production deployment
- Improved model optimization and inference performance

---

# Contributing

Contributions and improvements are welcome.

Create a feature branch:

```bash
git checkout -b feature/your-feature
```

Make and test your changes, then:

```bash
git add .
git commit -m "Add your feature"
git push origin feature/your-feature
```

Open a pull request from the feature branch.

---

# License

This project does not currently specify an open-source license.

Add a license file before distributing the project publicly if you intend to make the repository open source.

---

# Author

Developed as a full-stack software engineering project using Flutter, Spring Boot, MySQL, OCR, Python, and Qwen-based AI processing.
