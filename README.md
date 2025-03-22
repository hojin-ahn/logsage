# LogSage Alarm App

An AI-powered smart alarm app where you must solve a math problem to stop the alarm. Behind the scenes, all user actions (alarm triggers, errors, and successes) are logged and automatically analyzed using generative AI to provide insights into user behavior and app performance.

---

## Features

- **Alarm Scheduler**: Set alarms for specific days of the week and times.
- **Math Problem Alarm**: Solve a 3-digit addition problem to dismiss the alarm.
- **Sound Playback**: Repeating alarm sound until the correct answer is entered or time runs out.
- **Auto Timeout**: Alarm stops after 60 seconds with warning logged.
- **Event Logger**: All major app actions are logged with timestamps.
- **AI Log Analysis**: Logs are sent to a FastAPI backend and summarized by OpenAI.
- **Insight View**: Summarized results are displayed in-app for developers or testers.

---

## Architecture

Follows **Clean Architecture** principles:

lib/
├── core/
│   └── utils/
│       └── logger.dart
│       └── alarm_checker.dart
│   └── constants.dart
│
├── data/
│   └── datasources/
│       └── log_remote_datasource.dart
│   └── repositories/
│       └── log_repository_impl.dart
│
├── domain/
│   └── entities/
│       └── log_analysis_result.dart
│       └── alarm.dart
│   └── repositories/
│       └── log_repository.dart
│   └── usecases/
│       └── analyze_logs.dart
│
├── presentation/
│   ├── pages/
│   │   ├── log_analyzer_page.dart
│   │   ├── alarm_home_page.dart
│   │   └── alarm_ringing_page.dart
│   └── providers/
│       └── log_provider.dart
│       └── alarm_provider.dart
│
└── main.dart

---

## How It Works

1. The user sets alarms for certain times/days.
2. When time is matched, the alarm rings and plays a sound.
3. A math question is shown (e.g., 273 + 581 = ?).
4. If the correct answer is entered, the alarm stops. If not, logs are stored.
5. The backend summarizes the logs using OpenAI (GPT) and returns suggestions or insights.
6. The summary is shown in a developer dashboard inside the app.

---

## Tech Stack

| Layer       | Tech                          |
|-------------|-------------------------------|
| Frontend    | Flutter (Dart)                |
| Backend     | FastAPI (Python)              |
| AI Service  | OpenAI GPT (via API)          |
| Sound       | `audioplayers` Flutter plugin |

---

## Demo Scenarios

- Forget to answer the math problem → logged as `[WARNING]`
- Time runs out → `[ERROR] Auto-dismissed due to timeout`
- Correctly dismiss the alarm → `[INFO] Dismissed successfully`
- All logs are analyzed and summarized like:
  > "Most failures occur on Mondays around 7 AM. Consider adjusting difficulty or adding snooze options."

---

## Potential Extensions

- Custom alarm tones
- Dynamic difficulty adjustment based on performance
- Edge-case detection through logs
- Cloud-based log storage and analytics dashboard

---

## Setup

1. Clone the repo
2. Run `flutter pub get`
3. Run the app using `flutter run`