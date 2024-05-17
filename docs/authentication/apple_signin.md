# Adding Apple Sign-In to your app

> Apple Sign-In is only available on iOS devices for now.

## Backend configuration

> Here is the configuration needed for your backend to accept Apple Sign-In from mobile.
> It does not cover the configuration of the Apple Sign-In from web application.

Documentation extracted from [Flutter signin_with_apple package doc](https://pub.dev/packages/sign_in_with_apple)

---
### Setup
#### Register an App ID
If you don't have one yet, create a new one at https://developer.apple.com/account/resources/identifiers/list/bundleId following these steps:

Click "Register an App ID"
In the wizard select "App IDs", click "Continue"
Set the Description and Bundle ID of your app, and select the Sign In with Apple capability
Usually the default setting of "Enable as a primary App ID" should suffice here. If you ship multiple apps that should all share the same Apple ID credentials for your users, please consult the Apple documentation on how to best set these up.
Click "Continue", and then click "Register" to finish the creation of the App ID
In case you already have an existing App ID that you want to use with Sign in with Apple:

Open that App ID from the list
Check the "Sign in with Apple" capability
Click "Save"
If you have change your app's capabilities, you need to fetch the updated provisioning profiles (for example via Xcode) to use the new capabilities.

#### Create a Service ID
The Service ID is only needed for a Web or Android integration. If you only intend to integrate iOS you can skip this step.

Go to your apple developer page then "Identifiers" and follow these steps:

Next go to https://developer.apple.com/account/resources/identifiers/list/serviceId and follow these steps:

Click "Register an Services ID"
Select "Services IDs", click "Continue"
Set your "Description" and "Identifier"
The "Identifier" will later be referred to as your clientID
Click "Continue" and then "Register"
Now that the service is created, we have to enable it to be used for Sign in with Apple:

Select the service from the list of services
Check the box next to "Sign in with Apple", then click "Configure"
In the Domains and Subdomains add the domains of the websites on which you want to use Sign in with Apple, e.g. example.com. You have to enter at least one domain here, even if you don't intend to use Sign in with Apple on any website.
In the Return URLs box add the full return URL you want to use, e.g. https://example.com/callbacks/sign_in_with_apple
Click "Next" and then "Done" to close the settings dialog
Click "Continue" and then "Save" to update the service
In order to communicate with Apple's servers to verify the incoming authorization codes from your app clients, you need to create a key at https://developer.apple.com/account/resources/authkeys/list:

Click "Create a key"
Set the "Key Name" (E.g. "Sign in with Apple key")
Check the box next to "Sign in with Apple", then click "Configure" on the same row
Under "Primary App ID" select the App ID of the app you want to use (either the newly created one or an existing one)
Click "Save" to leave the detail view
Click "Continue" and then click "Register"
Now you'll see a one-time-only screen where you must download the key by clicking the "Download" button
Also note the "Key ID" which will be used later when configuring the server
---

Once this is done, in your backend environment variables, you need to add the following:

```bash
APPLE_ID=app_id
```

Now, let's generate a secret:
Here is some python code to easily generate a secret related to your APP_ID:

```python
from datetime import datetime, timedelta
import jwt

key_id = "YOUR_KEY_ID_FROM_PREVIOUS_STEP"
with open(f"AuthKey_{key_id}.p8", "r") as f:
    private_key = f.read()
team_id = "<YOUR_APPLE_TEAM_ID>"
client_app_id = "<YOUR_APP_ID>"

# in seconds
timestamp_now = datetime.now()
timestamp_exp = datetime.now() + timedelta(days=180)
data = {
    "iss": team_id,
    "iat": timestamp_now,
    "exp": timestamp_exp,
    "aud": "https://appleid.apple.com",
    "sub": client_app_id
}
token = jwt.encode(payload=data, key=private_key, algorithm="ES256", headers={"kid": key_id})
print(token)
```

Add this token to your backend environment variables:

```bash
APPLE_CLIENT_APP_SECRET=token
```
> Note that this token is valid for 6 months.

## Frontend IOS configuration
Open Xcode and move to `Runner` > `Targets` > `Runner` > `Signing & Capabilities` > `+ Capability` > Add `Sign in with Apple`

In `assets.env`, ensure `APPLE_LOGIN=true` is set.


