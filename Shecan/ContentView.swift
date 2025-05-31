//
//  ContentView.swift
//  Shecan
//
//  Created by Morteza on 5/31/25.
//

import SwiftUI

struct ContentView: View{
    @StateObject private var dnsManager = DNSManager()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Main content
            VStack(spacing: 5) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "network")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text("shecan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                }
                .padding(.top, 30)
                
                Spacer()
                
                // DNS Servers Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Shecan DNS Servers:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(dnsManager.dnsServers, id: \.self) { server in
                        Text(server)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding()
                .background(Color.black.opacity(0.2))
                .cornerRadius(10)
                
                Spacer()
                
                // Toggle Button
                Button(action: {
                    dnsManager.toggleDNS()
                }) {
                    if dnsManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    } else {
                        Text(dnsManager.isDNSEnabled ? "Disable shecan" : "Enable shecan")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                    }
                }
                .buttonStyle(NeumorphicButtonStyle(isActive: dnsManager.isDNSEnabled))
                .disabled(dnsManager.isLoading)
                
                Spacer()
                
                // Status indicator
                HStack {
                    Circle()
                        .fill(dnsManager.isDNSEnabled ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                        .shadow(color: dnsManager.isDNSEnabled ? Color.green.opacity(0.5) : Color.gray.opacity(0.5),
                               radius: 4, x: 0, y: 0)
                    
                    Text(dnsManager.isDNSEnabled ? "shecan is Active" : "shecan is Inactive")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert("DNS Status", isPresented: $dnsManager.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(dnsManager.alertMessage)
        }
        .onAppear {
            dnsManager.checkDNSStatus()
        }
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    var isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(isActive ? Color.red.opacity(0.5) : Color.blue.opacity(0.5))
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(isActive ? Color.red.opacity(0.3) : Color.blue.opacity(0.3))
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            .shadow(color: Color.black.opacity(0.2),
                    radius: configuration.isPressed ? 2 : 5,
                    x: configuration.isPressed ? 0 : 2,
                    y: configuration.isPressed ? 0 : 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed))
    }
}

#Preview {
    ContentView()
}
