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
                
                Spacer()
                
                // Toggle Button
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
                .padding([.bottom, .top], 15)
                
                //
                
                //start DNS Servers Info
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
