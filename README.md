# SOBA_Spring2025
Draft Repo for SOBA software development

## Discord
https://discord.gg/wwFQ8n5j

## Weekly GOAL

### Week 1(Jan 27 - Feb 2)
Create an app using flutter with just one button

## How to Run the App

This project includes **two separate apps**:
- First, run:
  ```bash
  flutter pub get
  ```
  to get all the dependencies
- Second, run the following command on your terminal.

## Organization App
To run the **organization** version of the app. Enter the following command on your terminal:

```bash
flutter run --flavor org -t lib/org_app/main_org.dart
```

## Responder (User) App
To run the **user** version of the app. Enter the following command on your terminal:

```bash
flutter run --flavor user -t lib/user_app/user_org.dart
```
- Lastly, after completing your testing, run the following command to clean your environment and reinstall your dependencies:
```bash
flutter clean
flutter pub get
```

