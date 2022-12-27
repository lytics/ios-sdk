# Lytics SDK for iOS

## Installation

You can add the Lytics SDK to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Add Packages...**
2. Enter `https://github.com/lytics/ios-sdk` into the package repository URL text field and click **Add Package**
3. Add the **Lytics** package product to your application target

## Usage

### Configuration

You must initialize the Lytics SDK with your [API token](https://learn.lytics.com/documentation/product/features/account-management/managing-api-tokens) before using it. If using an `AppDelegate`, it is recommended to do this in `AppDelegate.application(_:didFinishLaunchingWithOptions:)`:

```swift
import Lytics
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Lytics.shared.start(apiToken: "at.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") { configuration in
            ...
        }

        return true
    }
}
```

If you are using SwiftUI, you can initialize the SDK in the `App` initializer:

```swift
import Lytics
import SwiftUI

@main
struct MyApp: App {
    init() {
        Lytics.shared.start(apiToken: "at.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx") { configuration in
            ...
        }
    }

    var body: some Scene {
        ...
    }
}
```

## Sending Data

The Lytics event methods are generic, allowing you to define your own `Encodable` types and use the SDK with full type-safety.

```swift
struct MyIdentifier: Codable {
    var userID: String
    var email: String?
}

struct MyConsent: Codable {
    var document: String
    var consented: Bool
}

struct MyProperties: Codable {
    var eventID: Int
    var artist: Artist
}
```

### Identity Events

Tracking identity events provides an interface for updating the current user's properties stored on device as well as emitting an identify event to the downstream collections API.

```swift
Lytics.shared.identify(
    name: "login",
    identifiers: MyIdentifier(
        userID: "this-users-known-id",
        email: "some@email.com"))
```

### Consent Events

Consent events provide an interface for configuring and emitting a special event that represents an app users explicit consent. This event does everything a normal event does in addition to providing a special payload for consent details at the discretion of the developer.

```swift
Lytics.shared.consent(
    name: "ios consent",
    consent: MyConsent(
        document: "termsAndConditions",
        consented: true))
```

### Track Custom Events

Track custom events provides an interface for configuring and emitting a custom event at the customers discretion throughout their application (e.g. made a purchase or logged in)

```swift
Lytics.shared.track(
    name: "Buy Tickets",
    properties: MyProperties(
        eventID: event.id,
        artist: event.artist))
```

### Screen Events

Screen events provide an interface for configuring and emitting a special event that represents a screen or page view. It should be seen as an extension of the track method.

```swift
Lytics.shared.screen(name: Dashboard)
```

### Advertising ID

Before collecting the IDFA you must first add a [`NSUserTrackingUsageDescription`](https://developer.apple.com/documentation/bundleresources/information_property_list/nsusertrackingusagedescription) to your app's `Info.plist`. You can then call `Lytics.shared.requestTrackingAuthorization()` to have iOS request authorization to access the IDFA. Note that the alert will not be displayed if the user has turned off “Allow Apps to Request to Track” in the system privacy settings and that authorization can be revoked at any time.
