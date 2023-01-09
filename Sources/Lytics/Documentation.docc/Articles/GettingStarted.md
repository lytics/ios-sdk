# Getting Started

Learn how to install and configure the Lytics SDK.

## Installation

You can add the Lytics SDK to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Add Packages...**
2. Enter `https://github.com/lytics/ios-sdk` into the package repository URL text field and click **Add Package**
3. Add the **Lytics** package product to your application target

## Configuration

You must initialize the Lytics SDK with your [API token](https://learn.lytics.com/documentation/product/features/account-management/managing-api-tokens) before using it.

### App Delegate

If using an `AppDelegate`, it is recommended to do initialize the SDK in `AppDelegate.application(_:didFinishLaunchingWithOptions:)`:

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

### Pure SwiftUI

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
