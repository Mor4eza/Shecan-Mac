//
//  ContentView.swift
//  Shecan
//
//  Created by Morteza on 5/31/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dnsManager = DNSManager()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 5) {
                VStack(spacing: 1) {
                    Image(systemName: "network")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                    
                    Text("shecan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding([.top, .bottom], 30)
                
                
                // Network Adapter Picker
                HStack {
                    Text("Interface:")
                        .foregroundColor(.white)
                    
                    Picker("", selection: $dnsManager.selectedAdapter) {
                        ForEach(dnsManager.networkAdapters, id: \.self) { adapter in
                            Text(adapter).tag(adapter)
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 200)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    dnsManager.toggleDNS()
                }) {
                    if dnsManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                    } else {
                        Image(systemName: "power")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding()
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(isActive: dnsManager.isDNSEnabled))
                .frame(width: 50, height: 50)
                .disabled(dnsManager.isLoading)
                
                Spacer()
                
                HStack {
                    Circle()
                        .fill(dnsManager.isDNSEnabled ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                        .shadow(color: dnsManager.isDNSEnabled ? Color.green.opacity(0.5) : Color.gray.opacity(0.5),
                                radius: 4, x: 0, y: 0)
                    
                    Text(dnsManager.isDNSEnabled ?
                         "shecan is Active on \(dnsManager.selectedAdapter)" :
                         "shecan is Inactive on \(dnsManager.selectedAdapter)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding([.bottom, .top], 15)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shecan DNS Servers:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(dnsManager.dnsServers, id: \.self) { server in
                        HStack {
                            Text(server)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Text(dnsManager.pingTimes[server] ?? "Testing...")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(self.pingTimeColor(dnsManager.pingTimes[server]))
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .alert("DNS Status", isPresented: $dnsManager.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(dnsManager.alertMessage)
            }
        }
    }
    
    private func pingTimeColor(_ time: String?) -> Color {
        guard let time = time else { return .white }
        
        if time.contains("N/A") || time.contains("Error") || time.contains("Timeout") {
            return .red
        }
        
        if let msValue = Double(time.replacingOccurrences(of: " ms", with: "")) {
            if msValue < 50 { return .green }
            if msValue < 100 { return .yellow }
            return .orange
        }
        
        return .white
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    var isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        Circle()
                            .fill(isActive ? Color.red.opacity(0.5) : Color.blue.opacity(0.5))
                    } else {
                        Circle()
                            .fill(isActive ? Color.red.opacity(0.3) : Color.blue.opacity(0.3))
                    }
                }
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .shadow(color: Color.black.opacity(0.2),
                            radius: configuration.isPressed ? 2 : 5,
                            x: configuration.isPressed ? 0 : 2,
                            y: configuration.isPressed ? 0 : 3)
                    .scaleEffect(configuration.isPressed ? 1.0 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            )
    }
}

#Preview {
    ContentView()
        .environment(\.locale, .init(identifier: "fa"))
        .environment(\.layoutDirection, .rightToLeft )
}
