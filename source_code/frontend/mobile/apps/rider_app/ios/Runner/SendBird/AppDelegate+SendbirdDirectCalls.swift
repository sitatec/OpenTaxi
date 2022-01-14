import Flutter
import SendBirdCalls

let ERROR_CODE: String = "Sendbird Calls"

var callsChannel : FlutterMethodChannel?
var directCall : DirectCall?

extension AppDelegate: SendBirdCallDelegate, DirectCallDelegate {
    
    func enableSendbirdChannels(){

        // Setup the Flutter platform channles to receive calls from Dartside code
        let controller : FlutterViewController = self.window?.rootViewController as! FlutterViewController
        callsChannel = FlutterMethodChannel(name: "com.sendbird.calls/method",
                                                binaryMessenger: controller.binaryMessenger)
        callsChannel?.setMethodCallHandler({

            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            print("AppDelegate+SendbirdDirectCalls: enableSendbirdChannels: method type received: \(call.method)")
            
            switch call.method {
                case "init":
                    initSendbird(call: call) { (connected) -> () in
                        result(connected)
                        SendBirdCall.addDelegate(self, identifier: "flutter")
                        SendBirdCall.registerRemotePush(token: remoteNotificationToken) { (error) in
                            guard error == nil else {
                                // TODO: Handle error.
                                print("AppDelegate+SendbirdDirectCalls: initSendbird: ERROR: \(String(describing: error))")
                                DispatchQueue.main.async {
                                    let payload = [ "message": "\(String(describing: error))"]
                                    callsChannel?.invokeMethod("error", arguments: payload)
                                }
                                result(false)
                                return
                            }

                            // Handle registering the device token.
                            result(true)
                        }
                    }

                    return
                case "start_direct_call":
                    guard let args = call.arguments as? [String: Any] else {
                        result(FlutterError(code: ERROR_CODE, message: "FlutterMethodCall argument invalid", details: "Not expected [String:Any] type found: \(type(of:call.arguments))"))
                        return
                    }
                    guard let calleeId = args["callee_id"] as? String else {
                        result(FlutterError(code: ERROR_CODE, message: "Required FlutterMethodCall argument missing", details: "callee_id key-value missing"))
                        return
                    }
                    directCall = makeDirectCall(calleeId: calleeId, callDelegate: self) { directCall, error in
                        guard let e = error else {
                            return
                        }
                        result(FlutterError(code: ERROR_CODE, message: e.description, details: "\(e.errorCode)"))
                        result(true)
                    }
                    return
                case "answer_direct_call":
                    directCall?.accept(with: AcceptParams())
                    result(true)
                    return
                case "end_direct_call":
                    directCall?.end()
                    result(true)
                    return
                default:
                    result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
    }
    
    
    
    // SendbirdCallDelegate
    func didStartRinging(_ call: DirectCall) {
        
        print("AppDelegate+SendbirdDirectCalls: didStartRinging: call: \(call as AnyObject)")

        call.delegate = self
        directCall = call

        // Use CXProvider to report the incoming call to the system
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let name = call.caller?.userId ?? "Unknown"
        let nickname = call.caller?.nickname ?? "Unknown"

        
        // Inform Flutter layer
        DispatchQueue.main.async {
            let payload = [ "caller_id": name,
                            "caller_nickname":nickname]
            callsChannel?.invokeMethod("direct_call_received", arguments: payload)
        }
    }
    
    func didEstablish(_ call: DirectCall) {
        // Inform Flutter layer
        DispatchQueue.main.async {
            callsChannel?.invokeMethod("direct_call_established", arguments: nil)
        }
    }

    // DirectCallDelegates
    func didConnect(_ call: DirectCall) {
        // Inform Flutter layer
        DispatchQueue.main.async {
            callsChannel?.invokeMethod("direct_call_connected", arguments: nil)
        }
    }

    func didEnd(_ call: DirectCall) {
        // Inform Flutter layer
        DispatchQueue.main.async {
            callsChannel?.invokeMethod("direct_call_ended", arguments: nil)
        }
    }
    
}

// Call methods
func initSendbird(call: FlutterMethodCall, completion: @escaping (Bool) -> ()) {
    // Initialize Sendbird calls from Flutter
    
    guard let args = call.arguments as? Dictionary<String, Any> else {
        DispatchQueue.main.async {
            let payload = [ "message": "initSendbird: no args received"]
            callsChannel?.invokeMethod("error", arguments: payload)
        }
        return
    }
    
    guard let APP_ID = args["app_id"] as? String else {
        DispatchQueue.main.async {
            let payload = [ "message": "initSendbird: app_id missing from args"]
            callsChannel?.invokeMethod("error", arguments: payload)
        }
        completion(false)
        return
    }
    
    guard let userId = args["user_id"] as? String else {
        DispatchQueue.main.async {
            let payload = [ "message": "initSendbird: user_id missing from args"]
            callsChannel?.invokeMethod("error", arguments: payload)
        }
        completion(false)
        return
    }
    
    // Optional access token
    let accessToken = args["user_access_token"] as? String
    
    SendBirdCall.configure(appId: APP_ID)
    SBCLogger.setLoggerLevel(.info)
    let params = AuthenticateParams(userId: userId, accessToken: accessToken)
    
    SendBirdCall.authenticate(with: params) { (user, error) in
        
        guard let user = user, error == nil else {
            // Handle error.
            print("AppDelegate+SendbirdDirectCalls: initSendbird: ERROR: \(error as AnyObject)")
            DispatchQueue.main.async {
                let payload = [ "message": "initSendbird: authentication Error: \(error as AnyObject))"]
                callsChannel?.invokeMethod("error", arguments: payload)
            }
            completion(false)
            return
        }
        
        DispatchQueue.main.async {
            let payload = [ "message": "initSendbird: authenticated user: \(user as AnyObject))"]
            callsChannel?.invokeMethod("info", arguments: payload)
        }
        completion(true)
    }
}

func makeDirectCall(calleeId: String, callDelegate: DirectCallDelegate?, callCompletion: @escaping DirectCallHandler) -> DirectCall? {
    let params = DialParams(calleeId: calleeId, callOptions: CallOptions())
    let directCall = SendBirdCall.dial(with: params, completionHandler: callCompletion)
    directCall?.delegate = callDelegate
    return directCall
}