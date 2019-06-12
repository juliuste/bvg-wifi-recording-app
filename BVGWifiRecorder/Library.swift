//
//  Library.swift
//  BVGWifiRecorder
//
//  Created by Julius Tens on 12.06.19.
//  Copyright © 2019 Julius Tens. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

struct WifiInformation: Codable {
    let bssid: String
    let ssid: String
}

struct Recording: Codable {
    var wifi: WifiInformation?
    var line: String?
    var station: String?
    var direction: String?
}

struct Neighbor: Codable {
    let id: String
    let name: String
}

struct Station: Codable {
    let id: String
    let line: String
    let name: String
    let neighbors: [Neighbor]
}

func currentWifiInformation() -> WifiInformation? { // @todo
    var bssid: String?
    var ssid: String?
    let ifs = CNCopySupportedInterfaces() as? [Any]
    for ifnam in ifs as? [String] ?? [] {
        let info = CNCopyCurrentNetworkInfo(ifnam as CFString) as? [AnyHashable: Any]
        bssid = info?["BSSID"] as? String
        ssid = info?["SSID"] as? String
    }
    if (ssid != nil && bssid != nil) {
        return WifiInformation(bssid: bssid!, ssid: ssid!)
    }
    return nil
}

func ssidIsWhitelisted(_ ssid: String) -> Bool {
    return (Config.wifiSsidWhitelist == nil || Config.wifiSsidWhitelist!.contains(ssid))
}

func recordingIsComplete(_ recording: Recording) -> Bool {
    return (
        recording.wifi != nil && ssidIsWhitelisted(recording.wifi!.ssid)
        && recording.line != nil
        && recording.station != nil
        && recording.direction != nil
    )
}

func sendRecording(recording: Recording, onSuccess: (() -> Void)?, onFailure: (() -> Void)?) {
    var request = URLRequest(url: URL(string: Config.endpoint)!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = try! JSONEncoder().encode(recording)
    let task = URLSession.shared.dataTask(with: request) { _, response, error in
        guard let response = response as? HTTPURLResponse,
            error == nil else { DispatchQueue.main.async { onFailure?() }; return } // @todo
        guard (200...299) ~= response.statusCode else { DispatchQueue.main.async { onFailure?() }; return } // @todo
        DispatchQueue.main.async {
            onSuccess?()
        }
    }
    task.resume()
}
