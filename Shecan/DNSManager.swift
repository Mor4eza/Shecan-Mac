//
//  DNSManager.swift
//  Shecan
//
//  Created by Morteza on 5/31/25.
//

import Foundation

class DNSManager: ObservableObject {
    @Published var isDNSEnabled: Bool = false
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    let dnsServers = ["178.22.122.100", "185.51.200.2"]
    
    init() {
        checkDNSStatus()
    }
    
    func checkDNSStatus() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let currentDNS = self.getCurrentDNS()
            
            DispatchQueue.main.async {
                self.isDNSEnabled = currentDNS == self.dnsServers
                self.isLoading = false
            }
        }
    }
    
    func toggleDNS() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let currentDNS = self.getCurrentDNS()
            let shouldEnable = currentDNS != self.dnsServers
            
            let command: String
            if shouldEnable {
                command = "networksetup -setdnsservers Wi-Fi \(self.dnsServers.joined(separator: " "))"
            } else {
                command = "networksetup -setdnsservers Wi-Fi empty"
            }
            
            let process = Process()
            process.launchPath = "/bin/bash"
            process.arguments = ["-c", command]
            
            do {
                try process.run()
                process.waitUntilExit()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    if process.terminationStatus == 0 {
                        self.isDNSEnabled = shouldEnable
                        self.alertMessage = shouldEnable ? "DNS enabled successfully!" : "DNS disabled successfully!"
                        self.showAlert = false
                    } else {
                        self.alertMessage = "Failed to update DNS settings"
                        self.showAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }
    
    private func getCurrentDNS() -> [String] {
        let process = Process()
        let pipe = Pipe()
        
        process.launchPath = "/usr/sbin/networksetup"
        process.arguments = ["-getdnsservers", "Wi-Fi"]
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            if output.lowercased().contains("there aren't any dns servers") || output.isEmpty {
                return []
            } else {
                return output.components(separatedBy: "\n").filter { !$0.isEmpty }
            }
        } catch {
            return []
        }
    }
}
