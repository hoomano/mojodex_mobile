# Adding Google Sign-In to your app

## Prerequisites
Your backend must be configured to accept Google Sign-In by registering in environment variables the following values:
- `GOOGLE_CLIENT_ID`: The client ID of your Google Sign-In API.
- `GOOGLE_CLIENT_SECRET`: The client secret of your Google Sign-In API.

Those values can be obtained by registering you project on google cloud console (https://console.cloud.google.com/).
Then in "APIs and services" -> Credentials, you can create a new OAuth 2.0 client ID of type "Web application" for your server.

## Configure consent screen
In Google cloud console, in "APIs and services" go to "OAuth consent screen".
If you are planning to publish your app, choose the “External” option and click “CREATE”.
> Page 1: OAuth consent screen: Fill in the required fields
> Page 2: Scopes: No action needed
> Page 3: Test users: Add your email address if you want to test the consent screen in some phase
> Page 4: Summary: Click “BACK TO DASHBOARD”

## IOS configuration
### Google Cloud console
In Google cloud console, in "APIs and services" go to "Credentials".
Create a new OAuth 2.0 client ID of type "iOS" for your app.
Fill in the required fields including bundleIS and click "Create".
Copy the provided client ID. It is your GOOGLE_IOS_CLIENT_ID.

### Mojodex project
Open your info.plist file and add the following key:
```xml
<!-- Google Sign-in Section -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- TODO Replace this value: -->
            <string>REVERSED_GOOGLE_IOS_CLIENT_ID</string>
        </array>
    </dict>
</array>
<!-- End of the Google Sign-in Section -->
```
> ⚠️ GOOGLE_IOS_CLIENT_ID will look like this `something.apps.googleusercontent.com`
> REVERSED_GOOGLE_IOS_CLIENT_ID is the reverse of your GOOGLE_IOS_CLIENT_ID. It will look like this `com.googleusercontent.apps.something`

In `assets/.env` file, add the following line:
```env
GOOGLE_IOS_CLIENT_ID=
GOOGLE_SERVER_CLIENT_ID=
``` 
GOOGLE_SERVER_CLIENT_ID being the environment variable you set in your backend.

## Android configuration
### Sign your app
In order to use Google Sign-In, you need to sign your app with a keystore.
If you haven't done that yet, run:
```shell
keytool -genkey -v -keystore <path-to-your-project>/android/app/androidkey.jks -keyalg RSA -keysize 2048 -validity 10000 -alias keyalias
```

> This command generates a keystore file named “androidkey.jks” in the “android/app” directory of your project. You can choose a different name and alias if you prefer.

Then, open file `android/app/build.gradle` and add the following lines:
```gradle
android {
    ...
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
    signingConfigs {
        release {
            storeFile file("androidkey.jks")
            storePassword "storePassword"
            keyAlias "keyalias"
            keyPassword "keyPassword"
        }
    }
}
```

Finally, to get your SHA-1 key, run:
```shell
cd android
./gradlew signingReport
```

⚠️ There are many info in signingReport. Ensure to take the sha1 key from 'debug' or 'release' variant depending on your usecase !

Note this key, you will need it in the next step.

### Google Cloud console
In Google cloud console, in "APIs and services" go to "Credentials".
Create a new OAuth 2.0 client ID of type "Android" for your app.
Fill in the required fields including package name and click "Create".

> This is the moment you will need the SHA-1 key you noted before.

Copy the provided client ID. It is your GOOGLE_ANDROID_CLIENT_ID.

### Mojodex project
In `assets/.env` file, add the following line:
```env
GOOGLE_ANDROID_CLIENT_ID=
GOOGLE_SERVER_CLIENT_ID=
``` 
GOOGLE_SERVER_CLIENT_ID being the environment variable you set in your backend.