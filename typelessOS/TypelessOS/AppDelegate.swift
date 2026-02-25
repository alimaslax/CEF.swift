import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("TypelessOS app finished launching")
    }
    
    func applicationShouldTerminate(_: NSApplication) -> NSApplication.TerminateReply {
        print("TypelessOS should terminate")
        return .terminateNow
    }
}
