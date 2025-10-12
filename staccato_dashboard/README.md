# Staccato Dashboard

The `staccato_dashboard` is the primary user interface for the Staccato project. It is a Flutter application designed as a kiosk-style, always-on family hub. The core design philosophy is to create an experience that feels like a natural extension of family life—intuitive, helpful, and unobtrusive.

This application is built to be age-inclusive, with a strong focus on accessibility, clarity, and ease of use for every member of the family, from young children to adults.

## Core Principles

This project adheres to a strict set of design and development guidelines to ensure consistency, quality, and maintainability. These are defined in the project's `/steering` directory.

### Architecture

-   **MVC Pattern**: The application follows a strict Model-View-Controller (MVC) architecture for all screens.
    -   **Route (`*_route.dart`)**: A `StatefulWidget` that serves as the entry point for a screen and creates the controller.
    -   **Controller (`*_controller.dart`)**: Extends `State` and contains all business logic, state management, and event handling.
    -   **View (`*_view.dart`)**: A `StatelessWidget` that handles UI presentation and receives all state and methods from its controller.
-   **State Management**: State is managed simply and predictably using `setState()` within the controllers. Complex state management libraries (Bloc, Riverpod, etc.) are intentionally avoided.
-   **Backend**: The application uses Firebase for its backend services, including Firestore for the database and Firebase Authentication. The architecture is designed to operate within the constraints of the Firebase free tier.

### Coding Style & Documentation

-   **Style Guide**: All Dart and Flutter code adheres to the standards outlined in the `steering/flutter-coding-style.md` document. This includes conventions for file organization, widget composition, strong typing, and more.
-   **Linting**: The project uses the `very_good_analysis` package to enforce strict linting rules.
-   **Documentation**: All code must be thoroughly documented using Dartdoc (`///`) comments, as specified in `steering/documentation-standards.md`. Code without documentation is considered incomplete.

### Design Philosophy

-   **Age-Inclusive Design**: The UI prioritizes large touch targets, clear text, high-contrast color schemes, and simple navigation.
-   **Family-Centric Interface**: Features like color-coding for each family member and clear separation of personal vs. shared content are central to the design.
-   **Kiosk-Optimized**: The interface is designed for an always-on, glanceable experience, primarily in landscape mode.

## Getting Started

This is a standard Flutter project. To get started, ensure you have the Flutter SDK installed.

1.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

2.  **Run the application:**
    ```sh
    flutter run
    ```