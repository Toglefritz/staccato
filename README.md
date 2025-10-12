# Staccato

A comprehensive family management system designed to streamline household coordination, task management, and communication. Staccato uses a multi-agent AI architecture and optional companion hardware to provide adaptive, personalized family experiences. The project centers around a tablet-based dashboard but also includes supporting apps and a Firebase backend.

## System Architecture

Staccato employs a sophisticated multi-agent architecture integrating per-user agents, a coordinator agent, and a policy agent to deliver personalized, adaptive interactions. The system combines cloud services like Firebase, Cloud Run, and AI Studio with edge computing on companion hardware to ensure responsive and context-aware family management. For detailed architecture, see [Staccato Architecture](staccato-architecture.md).

## Project Vision

The Staccato dashboard provides a central hub for family life. Installed as a kiosk in a shared space (like a kitchen or living room), it helps families stay organized, connected, and in sync through adaptive, AI-driven interactions. Supporting mobile and web apps extend functionality to parents and ensure management is possible anywhere.

## Core Components

### 1. iPad Dashboard (Primary Interface)
- **Platform**: Flutter iOS app in kiosk mode  
- **Purpose**: Family coordination hub with adaptive AI-driven personalization  
- **Features**:
  - Task and chore management  
  - Family calendar with color-coded members and personalized scheduling  
  - Weather display  
  - Photo screensaver  
  - Sleep/wake scheduling  
  - Rewards tracking  
  - Academic practice  
  - Family-friendly entertainment

### 2. Parent Mobile App (Administrative)
- **Platform**: Flutter for iOS & Android  
- **Purpose**: Remote management, parental control, and AI-driven insights  
- **Features**:
  - Task assignment and tracking  
  - Calendar management  
  - Full administrative access  
  - Locks and parental controls  

### 3. Firebase Cloud Backend
- **Platform**: Firebase (Spark free tier)  
- **Services**: Firestore, Authentication, Storage, Cloud Functions  
- **Purpose**: Data storage, authentication, multi-device sync, and AI integration  
- **Features**:
  - Real-time updates across devices  
  - Family-level access controls  
  - Secure media storage for photos  

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
- **Functions**: Firebase Cloud Functions for custom logic and AI coordination  
- **Hosting**: Firebase Hosting for web dashboard  

See [Firebase Architecture](firebase-architecture.md) for details.

## Design Principles

The dashboard is guided by a family-first philosophy: simple, accessible, reliable, and adaptive. AI-driven personalization tailors the experience to each family member's needs and preferences.

- **Age-Inclusive**: Suitable for children and adults with personalized content  
- **Always-On**: Designed for kiosk use with minimal interaction required, adapting to family routines  
- **Color-Coded**: Each family member consistently represented with personalized cues  
- **Accessible**: High-contrast, large touch targets, customizable accessibility profiles  

See [Design Principles](family-dashboard-design-principles.md) for details.

## Development Guidelines

- **Coding Standards**: Strict MVC, strong typing, reusable widgets, and Flutter best practices ([Coding Standards](flutter-coding-style.md))  
- **Documentation**: Every class, function, and API endpoint must be documented ([Documentation Standards](documentation-standards.md))  
- **Testing**: Firebase Emulator Suite, unit/widget tests, accessibility tests  

## Disclaimer

In the creation of this application, artificial intelligence (AI) tools have been utilized. These tools have assisted in various stages of the tools's development, from initial code generation to the optimization of algorithms.

It is emphasized that the AI's contributions have been thoroughly overseen. Each segment of AI-assisted code has undergone meticulous scrutiny to ensure adherence to high standards of quality, reliability, and performance. This scrutiny was conducted by the sole developer responsible for the app's creation.

Rigorous testing has been applied to all AI-suggested outputs, encompassing a wide array of conditions and use cases. Modifications have been implemented where necessary, ensuring that the AI's contributions are well-suited to the specific requirements and limitations inherent in the technologies related to this app's functionality.

Commitment to the apps's accuracy and functionality is paramount, and feedback or issue reports from users are invited to facilitate continuous improvement.

It is to be understood that this tool, like all software, is subject to evolution over time. The developer is dedicated to its progressive refinement and is actively working to surpass the expectations of the community.