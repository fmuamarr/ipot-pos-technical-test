# IPOT — Customer QR Ordering App

A Flutter mobile application for table-side QR code ordering. Customers scan a QR code → browse the menu → add items to cart (with customizations) → submit an order → track its status in real time.

---

## Architecture

The project follows **Clean Architecture** with three distinct layers, using **GetX** for state management, routing, and dependency injection.

```
lib/
├── main.dart                        # Entry point — loads .env, bootstraps app
├── app/
│   └── infrastructure/
│       ├── bindings/app_binding.dart  # Root DI — wires all dependencies
│       └── routes/                    # GetX route definitions
├── domain/                            # Pure business logic — no Flutter deps
│   ├── entities/                      # Core data models (MenuItem, CartItem…)
│   ├── repositories/                  # Abstract contracts
│   └── usecase/                       # Single-responsibility use cases
├── data/                              # Implements domain contracts
│   ├── model/                         # JSON-serializable API models
│   ├── network/api_client.dart        # Dio HTTP client (reads API_BASE_URL from .env)
│   ├── datasource/                    # Remote data sources + mock fallback
│   └── repository/                    # Repository implementations
└── presentation/
    ├── home/          # QR Scanner (initial screen)
    ├── menu/          # Menu browser with tabs & search
    ├── cart/          # Cart screen + CartController (global, persistent)
    ├── order_confirmation/
    └── order_tracking/ # Polls order status every 10 s
```

### Key Decisions

| Decision | Rationale |
|---|---|
| **GetX** | Reactive state, DI, and routing in one package — no boilerplate |
| **Clean Architecture** | Domain layer is 100% testable without Flutter/Dio |
| **Mock fallback** | API calls fall back to inline mock data if the server is unreachable — works offline out of the box |
| **CartController** | Registered as `permanent: true` so cart persists across route changes |
| **flutter_dotenv** | `API_BASE_URL` read from `.env` — no hardcoded URLs in source |

---

## Features

- **QR Scanner** — Scans `ipot://table/{tableId}` deep-link format; validates and rejects invalid codes; "Demo Mode" button for instant testing without a physical QR code
- **Menu Browser** — Category tabs, full-text search, item cards with image placeholder
- **Item Customizations** — Per-group radio (single select) / checkbox (multi-select) controls; required group validation; live price preview
- **Cart** — Global reactive state; increment/decrement/remove; special instructions note; animated FAB showing item count + subtotal
- **Order Submission** — POSTs to API with correct request shape; mock fallback; loading/error states
- **Order Confirmation** — Animated success screen with order ID and estimated time
- **Order Tracking** *(Bonus)* — Polls `GET /api/v1/orders/{id}` every 10 s; visual stepper for `pending → confirmed → preparing → ready → served`

---

## Setup

### Prerequisites

- Flutter SDK ≥ 3.11.5
- Android Studio / Xcode for device/emulator

### Steps

```bash
git clone <repo-url>
cd ipot_pos

# Install dependencies
flutter pub get

# (Optional) edit API base URL
echo "API_BASE_URL=https://api.ipot.app" > .env

# Run on a connected device or emulator
flutter run
```

> **Note:** If the live API is unreachable the app automatically falls back to the bundled mock data — you can use it fully offline.

### Build APK

```bash
flutter build apk --release
```

### Build iOS

```bash
flutter build ipa
```

---

## Environment Config

| Variable | Default | Description |
|---|---|---|
| `API_BASE_URL` | `https://api.ipot.app` | Base URL for all API calls |

---

## Running Tests

```bash
flutter test
```

34 tests across 4 test files:
- `cart_controller_test.dart` — Cart state logic (add, remove, increment, subtotal, customizations)
- `menu_model_test.dart` — JSON parsing for menu API response + mock data
- `order_entity_test.dart` — `OrderStatus` parsing and display names
- `widget_test.dart` — Basic smoke test

---

## API Endpoints Used

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/v1/menu?table_id={id}` | Fetch menu for a table |
| `POST` | `/api/v1/orders` | Submit an order |
| `GET` | `/api/v1/orders/{id}` | Poll order status |

---

## Dependencies

| Package | Purpose |
|---|---|
| `get` | State management, routing, DI |
| `mobile_scanner` | QR / barcode scanning |
| `dio` | HTTP client |
| `cached_network_image` | Efficient network image loading |
| `flutter_dotenv` | `.env` file support |


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
