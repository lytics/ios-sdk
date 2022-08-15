import UIKit

// ------------------------------------------------------------------
// types
// ------------------------------------------------------------------

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

struct LyticsIdentity {
    var identifiers = [String: Any]()
    var attributes = [String: Any]()
}

struct LyticsEvent: Codable {
    var stream = ""
    var name = ""
    var identifiers = [String: String]()
    var properties = [String: String]()
    var callback = ""
}


// ------------------------------------------------------------------
// classes
// ------------------------------------------------------------------

// Lytics is the primary class for interacting with the Lytics SDK
class Lytics {

    private static var lyticsInstance: Lytics = {
        let lytics = Lytics()
        return lytics
    }()

    // Attributes
    var apiKey: String
    var accountId: String
    var user: LyticsUser
    
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
    
    // currentUser gets the current instance of LyticsUser and provides
    // all interfaces for getting, setting, and emitting the identity
    func currentUser() -> LyticsUser {
        return self.user
    }
    
    // identify provides an interface for updating the current users properties
    // as well as emitting an identify event to the downstream collections API
    func identify() {
        print("identify")
        return
    }
    
    // track provides an interface for configuring and emitting a user event at the
    // customers discretion throughout their application (e.g. made a purchase)
    func track(with: LyticsEvent) {
        let output = toJSON(payload: with)
        print("would track event: ", output)
        return
    }
    
    // screen provides an interface for configuring and emitting a special event that represents
    // a screen or pageview. this event type injects device properties into the payload before emitting
    func screen(with: LyticsEvent) {
        let output = toJSON(payload: with)
        print("would track screen interaction: ", output)
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
    
    // dispatch provides an interface for forcing a flushing of the event queue
    func dispatch() {
        print("dispatch")
    }
    
    // reset provides an interface for flushing all stored user information or state information related
    // to the Lytics mobile SDK
    func reset() {
        print("reset")
    }
    
    // Handlers /////////////////////////////////////////////////
    
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
    
    func generateUUID() -> String{
        return UUID().uuidString
    }
    
    func getStoredUser() -> Dictionary<String, Any> {
        return UserDefaults.standard.dictionary(forKey: "lyticsIdentity") ?? [String: Any]()
    }
    
    func updateStoredUser(identifiers: Dictionary<String, Any>) -> Dictionary<String, Any> {
        UserDefaults.standard.set(identifiers, forKey: "lyticsIdentity")
        return [String: Any]()
    }
    
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
        // TODO CHECK FOR USER
        
        // regardless if we have a stored user or not we need to ensure there is a stored anonymous
        // identifier "_uid" on the record. if there is not we need to generate one and store it.
        // TODO HANDLE UID CHECK AND STORE
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

// [STORY] developer initializes the instance
var options = LyticsConfigOptions()
options.apiKey = "my-api-key"
options.primaryIdentityKey = "_uid"
options.anonymouseIdentityKey = "_uid"
options.recordScreenViews = true
options.uploadInterval = 5000
options.maxQueueSize = 5000

var lytics = Lytics.sharedInstance()
lytics.start(with: options)

// [STORY] developer wants to ensure events are dispatched after app user has provided consent
Lytics.sharedInstance().optIn()

// [STORY] developer wants to ensure events are not dispatched after app user has revoked consent
Lytics.sharedInstance().optOut()

// [STORY] developer identifies the current app user
//Lytics.sharedInstance().identify()

// [STORY] developer wants to log some of the current app users stored identity data for testing
//print(Lytics.sharedInstance().currentUser())

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
var screen = LyticsEvent()
//event.stream = "ios"
//event.name = "cart_add"
//event.identifiers = [
//    "userId": "this-users-known-id-or-something",
//]
//event.properties = [
//    "orderId": "some-order-id",
//    "total": "19.95",
//]

lytics.screen(with: screen)

// [STORY] developer wants to include IDFA as part of app user's identifiers
//Lytics.sharedInstance().idfa()

// [STORY] developer wants to manually dispatch all events currently in the queue to minimize latency
Lytics.sharedInstance().dispatch()

// [STORY] developer flushes the instance when the app user logs out
Lytics.sharedInstance().reset()











// ----------

// user?.setConsentState(consentState)
// let user = MParticle.sharedInstance().identity.currentUser
// Create GDPR consent objects
// let locationCollectionConsent = MPGDPRConsent.init()
// locationCollectionConsent.consented = true
// locationCollectionConsent.document = "location_collection_agreement_v4"
// locationCollectionConsent.timestamp = Date.init()
// locationCollectionConsent.location = "17 Cherry Tree Lane"
// locationCollectionConsent.hardwareId = "IDFA:a5d934n0-232f-4afc-2e9a-3832d95zc702"
// let parentalConsent = MPGDPRConsent.init()
// parentalConsent.consented = false
// parentalConsent.document = "parental_consent_agreement_v2"
// parentalConsent.timestamp = Date.init()
// parentalConsent.location = "17 Cherry Tree Lane"
// parentalConsent.hardwareId = "IDFA:a5d934n0-232f-4afc-2e9a-3832d95zc702"
// // Only one CCPA consent object can be set - it has an implied purpose of `data sale opt-out`
// let ccpaConsent = MPCCPAConsent.init()
// ccpaConsent.consented = true; // true represents a "data sale opt-out", false represents the user declining a "data sale opt-out"
// ccpaConsent.document = "ccpa_consent_agreement_v2"
// ccpaConsent.timestamp = Date.init()
// ccpaConsent.location = "17 Cherry Tree Lane"
// ccpaConsent.hardwareId = "IDFA:a5d934n0-232f-4afc-2e9a-3832d95zc702"
// // Add to consent state
// let consentState = MPConsentState.init()
// consentState.addGDPRConsentState(locationCollectionConsent, purpose: "location_collection")
// consentState.addGDPRConsentState(parentalConsent, purpose: "parental")
// consentState.setCCPAConsentState(ccpaConsent)
// user?.setConsentState(consentState)
