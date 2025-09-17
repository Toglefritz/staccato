

# Staccato

A comprehensive family management system designed to streamline household coordination, task management, and communication. The project centers around a tablet-based dashboard but also includes supporting apps and a Firebase backend.

---

## Project Vision

The Staccato dashboard provides a central hub for family life. Installed as a kiosk in a shared space (like a kitchen or living room), it helps families stay organized, connected, and in sync. Supporting mobile and web apps extend functionality to parents and ensure management is possible anywhere.

---

## Core Components

### 1. iPad Dashboard (Primary Interface)
- **Platform**: Flutter iOS app in kiosk mode  
- **Purpose**: Family coordination hub  
- **Features**:
  - Task and chore management  
  - Family calendar with color-coded members  
  - Weather display  
  - Photo screensaver  
  - Sleep/wake scheduling
  - Rewards tracking
  - Academic practice
  - Family-friendly entertainment

### 2. Parent Mobile App (Administrative)
- **Platform**: Flutter for iOS & Android  
- **Purpose**: Remote management and parental control  
- **Features**:
  - Task assignment and tracking  
  - Calendar management  
  - Full administrative access  
  - Locks and parental controls  

### 3. Firebase Cloud Backend
- **Platform**: Firebase (Spark free tier)  
- **Services**: Firestore, Authentication, Storage, Cloud Functions  
- **Purpose**: Data storage, authentication, and multi-device sync  
- **Features**:
  - Real-time updates across devices  
  - Family-level access controls  
  - Secure media storage for photos  

---

## Technical Architecture

### Frontend
- **Framework**: Flutter single codebase  
- **Architecture**: Strict MVC pattern ([Coding Standards](flutter-coding-style.md))  
- **State Management**: Controller-driven with `setState()`  
- **Localization**: Flutter i18n with ARB files  

### Backend
- **Database**: Cloud Firestore (NoSQL, denormalized for performance)  
- **Authentication**: Firebase Auth with family-level roles  
- **Storage**: Firebase Storage for images and media  
- **Functions**: Firebase Cloud Functions for custom logic  
- **Hosting**: Firebase Hosting for web dashboard  

See [Firebase Architecture](firebase-architecture.md) for details.

---

## Design Principles

The dashboard is guided by a family-first philosophy: simple, accessible, and reliable.  

- **Age-Inclusive**: Suitable for children and adults  
- **Always-On**: Designed for kiosk use with minimal interaction required  
- **Color-Coded**: Each family member consistently represented  
- **Accessible**: High-contrast, large touch targets, customizable accessibility profiles  

See [Design Principles](family-dashboard-design-principles.md) for details.

---

## Development Guidelines

- **Coding Standards**: Strict MVC, strong typing, reusable widgets, and Flutter best practices ([Coding Standards](flutter-coding-style.md))  
- **Documentation**: Every class, function, and API endpoint must be documented ([Documentation Standards](documentation-standards.md))  
- **Testing**: Firebase Emulator Suite, unit/widget tests, accessibility tests