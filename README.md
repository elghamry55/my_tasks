# My Tasks – Task Management App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/State%20Management-Cubit-6C47FF" alt="Cubit State Management" />
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-3DDC84?logo=android&logoColor=white" alt="Android and iOS" />
</p>

A Flutter task management application that helps users organize their daily tasks, set due dates, and stay on track with scheduled reminders.

## Features

- Create tasks with a title, description, and due date and time.
- View tasks grouped into Today, Tomorrow, and Upcoming sections.
- Mark tasks as completed or active.
- Delete tasks.
- Store tasks locally using SQLite.
- Schedule local notifications as reminders before task deadlines.
- Support light and dark themes, following the system theme by default.
- Refresh the task list to load the latest data.

## Tech Stack

- **Flutter & Dart** – Cross-platform application development.
- **Cubit (flutter_bloc)** – State management.
- **SQLite (sqflite)** – Local task persistence.
- **Flutter Local Notifications** – Scheduled task reminders.
- **Intl** – Date and time formatting.
- **Google Fonts** – Typography.

## Project Structure

```text
lib/
├── core/
│   ├── notification_helper.dart
│   └── themes.dart
├── cubit/
│   ├── task_cubit.dart
│   └── task_state.dart
├── features/
│   ├── home/
│   │   ├── pages/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── splash_page/
│   └── models/
│       ├── data/
│       │   └── db_helper.dart
│       └── model/
│           └── task_model.dart
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK installed.
- Dart SDK compatible with the version specified in `pubspec.yaml`.
- Android Studio or another supported Flutter development environment.

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/elghamry55/my_tasks.git
   ```

2. Navigate to the project directory:

   ```bash
   cd my_tasks
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

## How Reminders Work

The app schedules a local notification for each task, intended to appear 10 minutes before its due date. If the due time has already passed when the reminder is scheduled, the app schedules the notification shortly afterward. Completing or deleting a task cancels its pending notification.

## Author

**Mahmoud Elghamry**

- GitHub: [@elghamry55](https://github.com/elghamry55)
