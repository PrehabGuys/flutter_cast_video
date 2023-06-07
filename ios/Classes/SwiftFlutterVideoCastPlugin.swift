import Flutter
import UIKit

public class SwiftFlutterVideoCastPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = AirPlayFactory(registrar: registrar)
        registrar.register(factory, withId: "AirPlayButton")
    }
}
