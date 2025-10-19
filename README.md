# Staccato

A comprehensive family management system designed to streamline household coordination, task management, and communication. Staccato uses a multi-agent AI architecture and optional companion hardware to provide adaptive, personalized experiences. The project centers around a tablet-based dashboard but also includes supporting apps and a backend deployed with Firebase and Google Cloud Run.

## System Architecture

Staccato employs a sophisticated multi-agent architecture integrating per-user agents, a coordinator agent, and a policy agent to deliver personalized, adaptive interactions. The system combines cloud services like Firebase and Cloud Run with edge computing on companion hardware to ensure responsive and context-aware family management. For detailed architecture, see [Staccato Architecture](./docs/staccato-architecture.md).

## Project Vision

The Staccato dashboard provides a central hub for home life. Installed as a kiosk in a shared space (like a kitchen or living room), it helps families stay organized, connected, and in sync through adaptive, AI-driven interactions. Supporting mobile and web apps extend functionality to parents and ensure management is possible anywhere.

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
- **Services**: Firestore, Authentication, Storage  
- **Purpose**: Data storage, authentication, multi-device sync, and media storage  
- **Features**:
  - Real-time updates across devices  
  - Family-level access controls  
  - Secure media storage for photos  

### 4. Google Cloud Run Backend
- **Platform**: Google Cloud Run  
- **Services**: Hosting backend microservices and agentic AI components developed with Google’s Agent Development Kit (ADK)  
- **Purpose**: Scalable, modular backend service hosting for multi-agent coordination and AI-driven logic  

## Technical Architecture

### Frontend
- **Framework**: Flutter single codebase  
- **Architecture**: Strict MVC pattern ([Coding Standards](./docs/development_standards/flutter-coding-style.md))  
- **State Management**: Controller-driven with `setState()`  
- **Localization**: Flutter i10n with ARB files  

### Backend
- **Database**: Cloud Firestore (NoSQL, denormalized for performance)  
- **Authentication**: Firebase Auth with family-level roles  
- **Storage**: Firebase Storage for images and media  
- **Services**: Google Cloud Run hosting backend microservices and AI agents built with Google’s Agent Development Kit (ADK)  
- **Hosting**: Firebase Hosting for web dashboard  

See [Firebase Architecture](./docs/development_standards/firebase-architecture.md) for details.

### Integration of Cloud Run and ADK

Google Cloud Run and the Agent Development Kit (ADK) form the backbone of Staccato's backend infrastructure. Cloud Run enables scalable, containerized deployment of backend microservices and AI agents, ensuring modularity and responsiveness. The ADK facilitates development and coordination of multi-agent AI components, allowing personalized and adaptive family management through seamless inter-agent communication and policy enforcement.

## Design Principles

The dashboard is guided by a user-centric philosophy: simple, accessible, reliable, and adaptive. AI-driven personalization tailors the experience to each family member's needs and preferences.

- **Age-Inclusive**: Suitable for children and adults with personalized content  
- **Always-On**: Designed for kiosk use with minimal interaction required, adapting to family routines  
- **Color-Coded**: Each family member consistently represented with personalized cues  
- **Accessible**: High-contrast, large touch targets, customizable accessibility profiles  

See [Design Principles](./docs/family-dashboard-design-principles.md) for details.

## Development Guidelines

- **Coding Standards**: Strict MVC, strong typing, reusable widgets, and Flutter best practices ([Coding Standards](./docs/development_standards/flutter-coding-style.md))  
- **Documentation**: Every class, function, and API endpoint must be documented ([Documentation Standards](./docs/development_standards/documentation-standards.md))  
- **Testing**: Firebase Emulator Suite, unit/widget tests, accessibility tests  

## Disclaimer

In the creation of this application, artificial intelligence (AI) tools have been utilized. These tools have assisted in various stages of the tools's development, from initial code generation to the optimization of algorithms.

It is emphasized that the AI's contributions have been thoroughly overseen. Each segment of AI-assisted code has undergone meticulous scrutiny to ensure adherence to high standards of quality, reliability, and performance. This scrutiny was conducted by the sole developer responsible for the app's creation.

Rigorous testing has been applied to all AI-suggested outputs, encompassing a wide array of conditions and use cases. Modifications have been implemented where necessary, ensuring that the AI's contributions are well-suited to the specific requirements and limitations inherent in the technologies related to this app's functionality.

Commitment to the apps's accuracy and functionality is paramount, and feedback or issue reports from users are invited to facilitate continuous improvement.

It is to be understood that this tool, like all software, is subject to evolution over time. The developer is dedicated to its progressive refinement and is actively working to surpass the expectations of the community.