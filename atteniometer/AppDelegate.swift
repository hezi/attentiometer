//
//  AppDelegate.swift
//  atteniometer
//
//  Created by Jorge Cohen on 14/05/2021.
//

import Cocoa
import AppKit
import Foundation
import ApplicationServices

func findWaitingRoomNotification(in element : AXUIElement) {
    var childrenPtr:CFTypeRef?
    AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenPtr)
    
    if childrenPtr == nil {
        return
    }
    
    let children = childrenPtr as! [AXUIElement]
    for c in children {
        let elem = c as! AXUIElement

        var desc:CFTypeRef?
        AXUIElementCopyAttributeValue(c, kAXDescriptionAttribute as CFString, &desc)

        if let desc = desc {
            let text = desc as! String
            if text.contains("entered the waiting room") {
                NSSound.beep()
                NSApp.requestUserAttention(.criticalRequest)
                return
            }
        } else {
            findWaitingRoomNotification(in: elem)
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if (!AXIsProcessTrusted()) {
            print("NOOOO");
        }

        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            let apps = NSWorkspace.shared.runningApplications
            let zoomm = NSWorkspace.shared.runningApplications.filter {$0.bundleIdentifier == "us.zoom.xos"}.first

            guard let zoom = zoomm, !zoom.ownsMenuBar else {
                return
            }
            
            if(zoom.ownsMenuBar){
                return
            }

            let app = AXUIElementCreateApplication(zoom.processIdentifier)

            var attArray:CFArray?
            AXUIElementCopyAttributeNames(app, &attArray)

            print(attArray ?? "nil")

            findWaitingRoomNotification(in: app)
        }
    }
    
    private func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) {
        let zoom = NSWorkspace.shared.runningApplications.filter {$0.bundleIdentifier == "us.zoom.xos"}.first!
        zoom.activate()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

