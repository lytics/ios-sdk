# Sending Data

Learn how to send data to the Lytics API.

## Define Event Models

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

## Identify Events

Identity events provide an interface for updating the current user's properties stored on device as well as emitting an identify event to the downstream collections API.

```swift
Lytics.shared.identify(
    name: "login",
    identifiers: MyIdentifier(
        userID: "this-users-known-id",
        email: "some@email.com"))
```

## Consent Events

Consent events provide an interface for configuring and emitting a special event that represents an app users explicit consent. This event does everything a normal event does in addition to providing a special payload for consent details at the discretion of the developer.

```swift
Lytics.shared.consent(
    name: "ios consent",
    consent: MyConsent(
        document: "termsAndConditions",
        consented: true))
```

## Custom Events

Track custom events provides an interface for configuring and emitting a custom event at the customers discretion throughout their application (e.g. made a purchase or logged in).

```swift
Lytics.shared.track(
    name: "Buy Tickets",
    properties: MyProperties(
        eventID: event.id,
        artist: event.artist))
```

## Screen Events

Screen events provide an interface for configuring and emitting a special event that represents a screen or page view. It should be seen as an extension of the track method.

```swift
Lytics.shared.screen(name: "Dashboard")
```

