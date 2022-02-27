//
//  IconsetCreatorApp.swift
//  IconsetCreator
//
//  Created by Mark Erbaugh on 11/4/21.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct TestOpenFileApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate  // close app when last window closed

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
