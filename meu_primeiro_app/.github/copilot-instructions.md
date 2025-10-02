# AI Agent Instructions for Todo List App

## Project Overview
This is a Flutter-based Todo List application that uses local storage (SharedPreferences) for data persistence. The app demonstrates a single-file architecture pattern common in small Flutter applications.

## Key Architecture Patterns

### Data Model
- Todo items are represented by the `Todo` class in `lib/main.dart`
- Each todo has a `title` (String) and `isDone` (bool) property
- JSON serialization is handled via `toJson()` and `fromJson()` methods

### State Management
- Uses Flutter's built-in `StatefulWidget` pattern
- State is managed in `_TodoListScreenState` class
- All todo operations (add/toggle/remove) trigger both state update (`setState`) and persistence

### Data Persistence
- Uses `shared_preferences` package for local storage
- Data is stored as JSON string under the key `todo_list`
- Key persistence methods:
  - `_loadTodos()`: Loads and deserializes todos on app start
  - `_saveTodos()`: Serializes and saves todos after each modification

## Development Workflows

### Setup and Running
```bash
flutter pub get        # Install dependencies
flutter run -d chrome # Run in web browser (primary target platform)
```

### Testing
Tests can be added in the `test/` directory following the pattern in `widget_test.dart`.

## Project Conventions
1. UI Structure:
   - Single screen application using `Scaffold`
   - Input field with add button at top
   - Scrollable list of todos below
   - Each todo item has checkbox and delete button

2. Code Organization:
   - Single file architecture (`lib/main.dart`)
   - Sections clearly marked with comments
   - Related functionality grouped together (UI, state management, persistence)

## Dependencies
- Flutter SDK (^3.9.0)
- shared_preferences: ^2.2.2 - For local storage
- flutter_lints: ^5.0.0 - For code quality

## Common Tasks
1. Adding new todo features:
   - Extend `Todo` class for new properties
   - Update JSON serialization methods
   - Add UI elements in `build()` method
   - Handle state/persistence in relevant methods

2. Modifying storage:
   - All storage operations in `_TodoListScreenState`
   - Always update both state (setState) and storage (_saveTodos)