//
//  ShecanApp.swift
//  Shecan
//
//  Created by Morteza on 5/31/25.
//

import SwiftUI

@main
struct ShecanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 320, height: 520)
                .colorScheme(.dark)
        }
        
        .windowResizability(.contentSize)
    }
}
