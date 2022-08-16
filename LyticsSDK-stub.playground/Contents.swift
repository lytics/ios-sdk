// the following is a high level stub or outline of the minimum functionality the
// Lytics mobile SDKs must provide. this stub is a work in progress and it should be
// assumed that additional methods and information will be necessary as we uncover
// gaps during the scoping process.
//
// starting at line 302 we have mocked and outlined the primary user stories that
// must be supported by this SDK

import UIKit

// ------------------------------------------------------------------
// types
// ------------------------------------------------------------------

// the following types are just rough examples of what would be necessary
// for handling the initial set of MVP event types. based upon the final
// scope this list will certainly be expanded but this demonstrates the
// similarity in all devent types

struct LyticsConfigOptions {
    var apiKey = ""
    var accountId = ""
    var primaryIdentityKey = ""
    var anonymouseIdentityKey = ""
    var recordScreenViews = false
    var uploadInterval = 1 // seconds (0=off)
    var maxQueueSize = 10 // records
    var sessionLength = 1200 // seconds
}

struct LyticsEvent: Codable {
    var stream = ""
    var name = ""
    var identifiers = [String: String]()
    var properties = [String: String]()
    var callback = ""
}

struct LyticsIdentityEvent {
    var stream = ""
    var name = ""
    var identifiers = [String: String]()
    var attributes = [String: String]()
    var sendEvent = true
    var callback = ""
}

struct LyticsConsentEvent {
    var stream = ""
    var name = ""
    var identifiers = [String: String]()
    var properties = [String: String]()
    var consent = [String: String]()
    var sendEvent = true
    var callback = ""
}


// ------------------------------------------------------------------
// classes
// ------------------------------------------------------------------

// the following are a very high level example of the two core classes that would
// likey be necessary which are user and lytics. this is absolutely example code
// and should be blown away but the key takeaway is that the core library needs
// to persist across screen views and integrate session type behavior. please note
// this example does NOT include all of the required helpers and methods. this is
// at the full discretion of the developer partner and shoudl be based upon final scope

class Lytics {

    private static var lyticsInstance: Lytics = {
        let lytics = Lytics()
        return lytics
    }()

    // Attributes
    var apiKey: String
    var accountId: String
    var user: LyticsUser
    var eventQueue: [String]
    
    // State
    var started: Bool
    
    // Options
    var trackApplicationLifecycleEvents: Bool
    var recordScreenViews: Bool
    var trackPushNotifications: Bool
    var trackDeepLinks: Bool
    var uploadInterval: Int // maximum number of ms to elapse between queue dispatches
    var maxQueueSize: Int // maximum queue size before forced dispatch
    var enableAdvertisingTracking: Bool
    var logLevel: String
    var environment: String
    
    // Initialize /////////////////////////////////////////////////
    
    private init() {
        self.apiKey = ""
        self.accountId = ""
        self.user = LyticsUser()
        self.started = false
        self.trackApplicationLifecycleEvents = true
        self.recordScreenViews = true
        self.trackPushNotifications = true
        self.trackDeepLinks = true
        self.uploadInterval = 5000
        self.maxQueueSize = 10
        self.enableAdvertisingTracking = false
        self.logLevel = "verbose"
        self.environment = "local"
    }

    class func sharedInstance() -> Lytics {
        return lyticsInstance
    }
    
    // API /////////////////////////////////////////////////
    
    func start(with: LyticsConfigOptions) {
        if (self.started) {
            print("instance has aleady been started")
            return
        }
        
        self.apiKey = with.apiKey
        self.accountId = with.accountId
        self.started = true
        // self.user = LyticsUser(config: config)
    }
    
    // currentUser gets the current instance of LyticsUser based on what has been stored
    // on the device as a result of identify events. though out of scope for the initial
    // project it should be assumed that in the future this will be expanded to load data
    // from an external api that contains greater knowledge of the user
    func currentUser() -> LyticsUser {
        return self.user
    }
    
    // identify provides an interface for updating the current users properties stored on
    // device as well as emitting an identify event to the downstream collections API
    func identify(with: LyticsIdentityEvent) {
        print("would handle identity event")
        return
    }
    
    // track provides an interface for configuring and emitting a custom event at the
    // customers discretion throughout their application (e.g. made a purchase or logged in)
    func track(with: LyticsEvent) {
        let output = toJSON(payload: with)
        print("would track event: ", output)
        return
    }
    
    // screen provides an interface for configuring and emitting a special event that represents
    // a screen or pageview. this event type injects device properties into the payload before emitting.
    // it should be seen as an extension of the track method
    func screen(with: LyticsEvent) {
        let output = toJSON(payload: with)
         print("would track screen interaction: ", output)
        return
    }
    
    // consent provides an interface for configuring and emitting a special event that represents
    // an app users expilcit consent. this event does everything a normal event does in addition to
    // providing a special payload for consent details at the discretion of the developer. it is likely
    // that the optIn/optOut methods will be included as part of the consent event depending on the
    // included consent status
    func consent(with: LyticsConsentEvent) {
        print("would handle consent event")
        return
    }
    
    // optIn provides an interface for enabling event collection if it was disabled by the app user at any point
    func optIn() {
        print("optIn")
    }

    // optOut provides an interface for preventing any further event collection until app user has opted in
    func optOut() {
        print("optOut")
    }
    
    // enableIDFA provides an interface for asking for access to the app users IDFA. if they consent this setting
    // should persist and the IDFA value should be included as part of the identifiers in all events
    func enableIDFA() {
        print("enableIDFA")
    }

    // disableIDFA provides an interface for disabling the behavior described in the enableIDFA method
    func disableIDFA() {
        print("disableIDFA")
    }
    
    // dispatch provides an interface for forcing a flushing of the event queue. it should also be assumed
    // that the event queue will be flushed automatically based on the global settings of a maximum time
    // as well as a maximum number of events, whichever wins
    func dispatch() {
        print("dispatch")
    }
    
    // reset provides an interface for flushing all stored user information or state information related
    // to the Lytics mobile SDK
    func reset() {
        print("reset")
    }
    
    // Handlers /////////////////////////////////////////////////
    
    // all outbound payloads to the lytics api(s) will be json encoded and included as the body of the POST
    func toJSON(payload: LyticsEvent) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(payload)
            let jsonString = String(data: data, encoding: .utf8)!
            return jsonString
        }
        catch {
            print("failed to convert to json")
            return ""
        }
    }
    
    // though there are a number of ways to do this we should include a helper to generate a UUID. this method
    // will also be used internally as a way of generating an anonymous identifier for the app user
    func generateUUID() -> String{
        return UUID().uuidString
    }
    
    // identity data must persist on the device to ensure proper identity resolution
    func getStoredUser() -> Dictionary<String, Any> {
        return UserDefaults.standard.dictionary(forKey: "lyticsIdentity") ?? [String: Any]()
    }
    
    // sample update method for demonstration purposes of the locally stored identity data
    func updateStoredUser(identifiers: Dictionary<String, Any>) -> Dictionary<String, Any> {
        UserDefaults.standard.set(identifiers, forKey: "lyticsIdentity")
        return [String: Any]()
    }
    
    // there are a number of steps reqiured to prepare an event before it is dispatched to the Lytics
    // collection APIs. it should be assumed that we will require injecting information into the provided
    // payload, constructing the endpiont based on the event details, etc. in many cases the endpoint path
    // will be altered based on the default stream or the stream passed as part of the payload:
    // https://learn.lytics.com/documentation/developer/api-docs/data-upload#bulk-json-upload
    func prepareEvent() {
        return
    }

}

// LyticsUser is the primary class for interacting with the current users identity on the device
class LyticsUser {
        
    // Attributes
    
    var primaryIdentityKey: String
    var anonymouseIdentityKey: String
    var identifiers: Dictionary<String, Any>
    var attributes: Dictionary<String, Any>

    // Initialize
    
    init() {
        self.primaryIdentityKey = "_uid"
        self.anonymouseIdentityKey = "_uid"
        self.identifiers = [String: Any]()
        self.attributes = [String: Any]()
        
        // when the SDK is initialized we need to determine if there is a stored user identity
        // if there is we need to set that to the default values
        
        // regardless if we have a stored user or not we need to ensure there is a stored anonymous
        // identifier "_uid" on the record. if there is not we need to generate one and store it.
    }
    
    // API
    
    // keyValue provides and interface for pulling the value associated with
    // the primaryIdentityKey. this will be "_uid" by default
    func keyValue() {
        print("would be the value for the set primary key")
    }
    
    // update allows for all configurable properties of the LyticsUser to be updated
    func update() {
        print("would update user")
    }
    
    // Private
    
    // generateUUID generates a unique value to be used as the anonymous identifier value
    func generateUUID() -> String{
        return UUID().uuidString
    }
    
}

// ------------------------------------------------------------------
// implementation
// ------------------------------------------------------------------

// [STORY] developer initializes the instance (note: this does not outline all required configuration options)
var options = LyticsConfigOptions()
options.apiKey = "my-api-key"               // the customers collection api key
options.primaryIdentityKey = "_uid"         // the key that represents the core identifier to be used in api calls
options.anonymouseIdentityKey = "_uid"      // the key which we use to store the anonymous identifier
options.recordScreenViews = true            // example of a flag for automatically collecting screen information
options.uploadInterval = 5000               // example of a queue setting to determine how often its flushed
options.maxQueueSize = 10                   // example of a queue setting to determine maximum events before flushing

var lytics = Lytics.sharedInstance()
lytics.start(with: options)

// [STORY] developer wants to ensure events are dispatched after app user has provided consent
Lytics.sharedInstance().optIn()

// [STORY] developer wants to ensure events are not dispatched after app user has revoked consent
Lytics.sharedInstance().optOut()

// [STORY] developer emits an event with details specific to consent/GDPR and simultaniously opts the app user in
var consentEvent = LyticsConsentEvent()
consentEvent.stream = "iosConsent"
consentEvent.sendEvent = true
consentEvent.identifiers = [
    "userId": "this-users-known-id-or-something",
    "email": "someemail@lytics.com",
]
consentEvent.properties = [
    "firstName": "Mark",
    "lastName": "Hayden",
    "title": "VP Product",
]
consentEvent.consent = [
    "document": "gdpr_collection_agreement_v1",
    "timestamp": "46236424246",
    "consented": "true",
]

lytics.consent(with: consentEvent)


// [STORY] developer identifies the current app user
var idEvent = LyticsIdentityEvent()
idEvent.stream = "iosIdentify"
idEvent.sendEvent = true
idEvent.identifiers = [
    "userId": "this-users-known-id-or-something",
    "email": "someemail@lytics.com",
]
idEvent.attributes = [
    "firstName": "Mark",
    "lastName": "Hayden",
    "title": "VP Product",
]

lytics.identify(with: idEvent)

// [STORY] developer wants to log some of the current app users stored identity data for testing
var currentUser = Lytics.sharedInstance().currentUser()

// [STORY] developer tracks an interaction when the app user adds an item to their cart
var event = LyticsEvent()
event.stream = "ios"
event.name = "cart_add"
event.identifiers = [
    "userId": "this-users-known-id-or-something",
]
event.properties = [
    "orderId": "some-order-id",
    "total": "19.95",
]

lytics.track(with: event)

// [STORY] developer wants to track a screen event when the app user navigates to a new view
var screenEvent = LyticsEvent()
screenEvent.stream = "ios"
screenEvent.name = "cart_add"
screenEvent.identifiers = [
    "userId": "this-users-known-id-or-something",
]
screenEvent.properties = [
    "orderId": "some-order-id",
    "total": "19.95",
]

lytics.screen(with: screenEvent)

// [STORY] developer wants to include IDFA as part of app user's identifiers
Lytics.sharedInstance().disableIDFA()

// [STORY] developer wants to manually dispatch all events currently in the queue to minimize latency
Lytics.sharedInstance().dispatch()

// [STORY] developer flushes the instance when the app user logs out
Lytics.sharedInstance().reset()
