//
//  MenuBarContentView.swift
//  Shecan
//
//  Created by Morteza on 6/6/25.
//


import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var dnsManager: DNSManager
    
    var body: some View {
        // Status item
        Text(dnsManager.isDNSEnabled ? 
             "Shecan is Active (\(dnsManager.selectedAdapter))" : 
             "Shecan is Inactive (\(dnsManager.selectedAdapter))")
            .disabled(true)
        
        Divider()
        
        // Toggle action
        Button {
            dnsManager.toggleDNS()
        } label: {
            Text(dnsManager.isDNSEnabled ? "Disable Shecan DNS" : "Enable Shecan DNS")
        }
        
        // Network interfaces
        Menu("Network Interface") {
            ForEach(dnsManager.networkAdapters, id: \.self) { adapter in
                Button {
                    dnsManager.selectedAdapter = adapter
                } label: {
                    HStack {
                        Text(adapter)
                        if adapter == dnsManager.selectedAdapter {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        
        Divider()
        
        // Ping status
        VStack(alignment: .leading) {
            Text("Ping Status:")
                .font(.headline)
            ForEach(dnsManager.dnsServers, id: \.self) { server in
                HStack {
                    Text(server)
                    Text(dnsManager.pingTimes[server] ?? "Testing...")
                        .foregroundColor(pingTimeColor(dnsManager.pingTimes[server]))
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        
        Divider()
        
        // Open main window and quit
        Button("Open Shecan") {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
    
    private func pingTimeColor(_ time: String?) -> Color {
        guard let time = time else { return .secondary }
        
        if time.contains("N/A") || time.contains("Error") || time.contains("Timeout") {
            return .red
        }
        
        if let msValue = Double(time.replacingOccurrences(of: " ms", with: "")) {
            if msValue < 50 { return .green }
            if msValue < 100 { return .yellow }
            return .orange
        }
        
        return .secondary
    }
}
