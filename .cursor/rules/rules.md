# Cursor Rules – Flutter + Firebase (Strict MVVM)

## Project Goal
This project is a **production-ready Flutter portfolio app** published on the App Store and Google Play.
Code quality, scalability, and clean architecture are mandatory.

---

## Architecture Overview

Use a **strict MVVM architecture** with a **feature-first folder structure**.

Each feature MUST contain the following layers:

- view/        → Flutter UI only
- viewmodel/   → State & business logic
- repository/  → Abstraction layer
- service/     → Firebase access only
- model/       → Immutable data models

Do NOT create files outside this structure unless explicitly required.

---

## Layer Responsibilities

### View (UI Layer)

- Contains ONLY Flutter UI code
- Uses Provider to observe ViewModels
- Triggers ViewModel methods
- Handles navigation and UI rendering only

Forbidden in Views:
- Business logic
- Firebase access
- Firestore queries
- Data transformation
- try/catch blocks
- JSON parsing

---

### ViewModel

- Manages UI state and business logic
- Communicates ONLY with repositories
- Uses Provider for state management
- Handles loading, success, and error states
- Converts errors into UI-friendly states

Allowed:
- try/catch
- State management
- Calling repository methods

Forbidden:
- Firebase imports
- Firestore/Auth/Storage access
- Direct service access
- JSON parsing

---

### Repository

- Acts as an abstraction layer between ViewModel and Service
- Delegates data operations to Services
- Contains NO Firebase code
- Contains NO UI logic

---

### Service (Firebase Layer)

- The ONLY place where Firebase is allowed
- Handles:
  - FirebaseAuth
  - FirebaseFirestore
  - FirebaseStorage
- Performs data fetching and persistence
- Throws custom exceptions
- Contains NO UI or state logic

---

## Firebase Rules (Hard Rules)

- FirebaseAuth, FirebaseFirestore, and FirebaseStorage
  MUST be used ONLY inside service classes

Never access Firebase from:
- Views
- ViewModels
- Repositories

---

## Models & Data Rules

- All models MUST be immutable
- Use `freezed` + `json_serializable`
- No mutable fields
- No setters
- Use `copyWith` for updates

Expected model style:
- Immutable
- Serializable
- Explicit typing

---

## Error Handling

- Services throw custom exceptions
- ViewModels catch errors using try/catch
- ViewModels expose error states/messages
- Views NEVER handle exceptions directly

---

## State Management

- Provider is the only state management solution
- ViewModels are ChangeNotifiers
- Views listen to ViewModels via Provider
- No global mutable state

---

## Naming Conventions

### Files & Folders
- snake_case.dart for files
- lower_case for folders

### Classes
- FeatureView
- FeatureViewModel
- FeatureRepository
- FeatureService
- FeatureModel

Examples:
- LoginView
- AuthViewModel
- AuthRepository
- AuthService
- AppUser

---

## Code Quality Rules

- Prefer readability over cleverness
- No large methods (> 40 lines)
- Extract logic into small, reusable methods
- Avoid duplication
- Follow single-responsibility principle

---

## Cursor Behavior Rules

- Respect existing architecture and folder structure
- Refactor existing code if it violates MVVM
- Do NOT mix UI and business logic
- Do NOT introduce new patterns without justification
- Add TODO comments only when meaningful
- It is allowed to modify existing files if required

---

## Absolute Don’ts

- No Firebase imports outside service layer
- No business logic inside Widgets
- No mutable models
- No direct JSON parsing in ViewModels
- No god classes
- No debug prints in production code

---

## Feature Folder Template

features/example/
  view/
    example_view.dart

  viewmodel/
    example_view_model.dart

  repository/
    example_repository.dart

  service/
    example_service.dart

  model/
    example_model.dart

---

## App Store Readiness

- Code must be production-ready
- All async states must be handled
- User-friendly error messages
- No debug logs
- Clean separation of concerns
- Scalable and maintainable structure

---

## Recommended Workflow

When creating a new feature:
1. Create model
2. Create service
3. Create repository
4. Create viewmodel
5. Create view

Always follow this order.