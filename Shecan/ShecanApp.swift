//
//  ShecanApp.swift
//  Shecan
//
//  Created by Morteza on 5/31/25.
//

import SwiftUI

@main
struct ShecanApp: App{
    @StateObject private var dnsManager = DNSManager()
    @State private var showWindow = false
    
    var body: some Scene {
        // Main window
//        WindowGroup {
//            ContentView()
//                .environmentObject(dnsManager)
//                .frame(width: 320, height: 520)
//                .colorScheme(.dark)
//        }
//        .windowResizability(.contentSize)
//        .commands {
//            CommandGroup(replacing: .appTermination) {
//                Button("Quit Shecan") {
//                    NSApplication.shared.terminate(nil)
//                }
//                .keyboardShortcut("q")
//            }
//        }
        
        // Menu bar extra
        MenuBarExtra {
            ContentView()
                .frame(width: 320, height: 520)
                .environmentObject(dnsManager)
        } label: {
            Image(systemName: dnsManager.isDNSEnabled ? "network" : "network.slash")
        }
        .menuBarExtraStyle(.window)
    }
}

