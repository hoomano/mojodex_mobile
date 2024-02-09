# MOJODEX MOBILE APP

The Mojodex Mobile App is an open-source Flutter application, part of the Mojodex digital assistant platform.

Designed to help businesses and individuals with their specific tasks and processes, Mojodex provides a task-oriented, configurable, and personalizable experience on-the-go.

## Prerequisites

### Flutter

See the [Flutter installation guide](https://flutter.dev/docs/get-started/install) for details on how to install Flutter on your machine.

### Mojodex Backend
To build and use the Mojodex Mobile App, you must have the Mojodex backend running on your local machine or a remote server.

Follow the instructions in the [Mojodex README](https://github.com/hoomano/mojodex) to set up and run the project.

⚠️ The Mojodex mobile app experience is completely voice interactive. You have to set a WHISPER configuration in Mojodex platform before deploying your backend to use mobile app.

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
cd ..
```

STEP 3: Set up your BACKEND_URI in the .env file
```
cd assets
cp .env.example .env
```
Edit the .env file and set your IP address:
```
BACKEND_URI="http://<your_ip_address>:5001"
```

STEP 4: Run the Mojodex Mobile App
```
cd ..
flutter run
```

If running on IOS device, you may be prompted to set a development team. Follow the instructions in Xcode to do so.

> 🎉 Congratulations
>
> You can now access your Mojodex instance and manage your tasks, and more through the mobile app!
