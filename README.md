# Object Manager

A cross-platform Flutter application for managing objects via REST API, built as a test task for the **Logiks Solutions Flutter Developer Trainee** position.

## Overview

Object Manager is a fully functional CRUD application that connects to the [restful-api.dev](https://api.restful-api.dev) public API. It demonstrates clean architecture principles, BLoC state management, and professional UI/UX patterns including shimmer loading, Hero animations, dark/light theming, and comprehensive error handling.

## Architecture

| Layer | Technology |
|---|---|
| **State Management** | BLoC / Cubit (`flutter_bloc`) |
| **Networking** | Dio with configurable headers and timeouts |
| **Navigation** | GoRouter with declarative routing |
| **Pattern** | Feature-based Clean Architecture |
| **Persistence** | SharedPreferences (theme, auth credentials) |
| **API** | [https://api.restful-api.dev](https://api.restful-api.dev) |

## Features

**Core (Required)**
- Browse objects in a scrollable list showing ID and name
- View all available details for a selected object
- Create new objects with name and dynamic key-value data fields
- Edit existing objects (pre-populated form)
- Delete objects with confirmation dialog

**Enhanced (Bonus)**
- Pull-to-refresh
- Shimmer loading skeletons (list and detail screens)
- Empty state and error state with retry
- Local search/filtering by name or ID
- Hero animations between list and detail screens
- Unsaved changes protection (back-navigation warning)
- Form validation
- Dark / Light / System theme toggle (persisted)
- Smooth animated theme transitions via `ThemeExtension` + `lerp`
- Authenticated collection mode (API key + collection name)
- Optimistic UI updates on delete
- Dynamic data fields — add/remove key-value pairs on create/edit

## Screens

| # | Screen | Description |
|---|---|---|
| 1 | **Splash** | Gradient background with staggered fade-in animations (logo, title, loader) |
| 2 | **Object List** | Cards with name, ID, data chips; FAB for create; search toggle; shimmer loading; empty/error states |
| 3 | **Object Detail** | Object name with Hero animation, ID badge, specifications table, edit/delete actions |
| 4 | **Create / Edit** | Name field, dynamic key-value data pairs with add/remove, save button with loading spinner |
| 5 | **Settings** | API key & collection name inputs, appearance toggle (Light/Dark/System), auth status indicator |

## Project Structure

```
lib/
├── core/
│   ├── constants/       # Spacing, timing values
│   ├── network/         # Dio API client, endpoint definitions
│   ├── services/        # AuthService (SharedPreferences)
│   ├── theme/           # AppColors (ThemeExtension), AppTheme, ThemeCubit
│   └── widgets/         # Shimmer loading, error view, empty state
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── bloc/         # AuthCubit
│   │       └── screens/      # SettingsScreen
│   └── objects/
│       ├── data/
│       │   ├── models/       # ApiObject model (fromJson/toJson, copyWith)
│       │   └── repositories/ # ObjectRepository (public + authenticated endpoints)
│       └── presentation/
│           ├── bloc/         # ObjectListBloc, ObjectDetailCubit, ObjectFormCubit
│           ├── screens/      # Splash, List, Detail, Form
│           └── widgets/      # ObjectCard, ObjectDetailSection
├── app.dart                  # MaterialApp, GoRouter, BLoC providers
└── main.dart                 # Entry point
```

## State Management

| Component | Type | Responsibilities |
|---|---|---|
| **ObjectListBloc** | BLoC (event-driven) | Load, refresh, search, delete, add objects |
| **ObjectDetailCubit** | Cubit | Load object details, delete with error handling |
| **ObjectFormCubit** | Cubit | Create, update (PUT/PATCH), error parsing |
| **ThemeCubit** | Cubit | Theme mode switching, persistence |
| **AuthCubit** | Cubit | Credential management, auth state |

## API Modes

The app supports two modes:

- **Public Mode** — Uses the public endpoints at `/objects` (default, no credentials needed)
- **Authenticated Mode** — Uses collection-based endpoints at `/collections/{name}/objects` with an API key header, allowing private object management

Configure credentials in the Settings screen.

## Getting Started

**Prerequisites:**
- Flutter 3.29+
- Dart 3.7+

**Run:**
```bash
cd object_manager
flutter pub get
flutter run
```

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | BLoC/Cubit state management |
| `dio` | HTTP client with interceptors and timeouts |
| `go_router` | Declarative navigation and routing |
| `shimmer` | Loading skeleton animations |
| `google_fonts` | Inter font for clean typography |
| `equatable` | Value equality for states and events |
| `shared_preferences` | Local persistence for theme and credentials |

