# MOJODEX MOBILE APP

The Mojodex Mobile App is an open-source mobile application for the Mojodex digital assistant platform.
Designed to help businesses and individuals with their specific tasks and processes, Mojodex provides a task-oriented, configurable, and personalizable experience on-the-go.

## Prerequisites

To use the Mojodex Mobile App, you must have the Mojodex backend running on your local machine or a remote server.
Follow the instructions in the [Mojodex README](https://github.com/hoomano/mojodex) to set up and run the project.

## Getting Started

STEP 1: Clone the repository

```
git clone https://github.com/hoomano/mojodex_mobile.git
cd mojodex_mobile
```

STEP 2: Install dependencies

If building on IOS, ensure cocoapods is up to date
```
sudo gem update cocoapods
```

```
flutter pub get
```
If building on IOS,
```
cd ios
pod install
pod update
```

STEP 3: Set up your BACKEND_URI in the .env file
```
cp .env.example .env
```
Edit the .env file and set your IP address:
```
BACKEND_URI="http://<your_ip_address>:5001"
```

STEP 4: Run the Mojodex Mobile App
```
flutter run
```

> 🎉 Congratulations
>
> You can now access your Mojodex instance and manage your tasks, and more through the mobile app!
