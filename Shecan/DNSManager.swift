//
//  DNSManager.swift
//  Shecan
//
//  Created by Morteza on 5/31/25.
//

import SwiftUI
import Combine

class DNSManager: ObservableObject {
    @Published var isDNSEnabled: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var pingTimes: [String: String] = [:]
    @Published var networkAdapters: [String] = []
    @Published var selectedAdapter: String = "Wi-Fi" {
        didSet {
            checkDNSStatus()
        }
    }
    
    let dnsServers = ["178.22.122.100", "185.51.200.2"]
    
    @Published var currentLocale: Locale = .english {
          didSet {
              // Update app's locale when changed
              UserDefaults.standard.set([currentLocale.identifier], forKey: "AppleLanguages")
              UserDefaults.standard.synchronize()
          }
      }
      
      // Supported languages
      let supportedLocales: [Locale] = [.english, .persian]
      
    
    init() {
        fetchNetworkAdapters()
        checkDNSStatus()
    }
    
    func fetchNetworkAdapters() {
        DispatchQueue.global(qos: .background).async {
            let process = Process()
            let pipe = Pipe()
            
            process.launchPath = "/usr/sbin/networksetup"
            process.arguments = ["-listallnetworkservices"]
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                let adapters = output.components(separatedBy: "\n")
                    .filter { !$0.isEmpty && !$0.contains("An asterisk (*)") }
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                DispatchQueue.main.async {
                    self.networkAdapters = adapters
                    if !adapters.isEmpty && !adapters.contains(self.selectedAdapter) {
                        self.selectedAdapter = adapters[0]
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to fetch network adapters"
                    self.showAlert = true
                }
            }
        }
    }
    
    func pingDNSServers() {
        for server in dnsServers {
            DispatchQueue.global(qos: .utility).async {
                let time = self.getPingTime(host: server)
                DispatchQueue.main.async {
                    self.pingTimes[server] = time
                }
            }
        }
    }
    
    private func getPingTime(host: String) -> String {
        let process = Process()
        let pipe = Pipe()
        
        process.launchPath = "/sbin/ping"
        process.arguments = ["-c", "3", host]
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else { return "N/A" }
            
            // Parse the average ping time
            if let range = output.range(of: "min/avg/max/stddev = ") {
                let remaining = output[range.upperBound...]
                let components = remaining.components(separatedBy: "/")
                if components.count >= 2 {
                    let avgTime = components[1]
                    return "\(avgTime) ms"
                }
            }
            return "Timeout"
        } catch {
            return "Error"
        }
    }
    
    func checkDNSStatus() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let currentDNS = self.getCurrentDNS()
            
            DispatchQueue.main.async {
                self.isDNSEnabled = currentDNS == self.dnsServers
                self.isLoading = false
                self.pingDNSServers()
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
                command = "networksetup -setdnsservers \(self.selectedAdapter) \(self.dnsServers.joined(separator: " "))"
            } else {
                command = "networksetup -setdnsservers \(self.selectedAdapter) empty"
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
                        self.pingDNSServers()
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
        process.arguments = ["-getdnsservers", selectedAdapter]
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
