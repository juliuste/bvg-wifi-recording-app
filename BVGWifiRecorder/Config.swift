//
//  Config.swift
//  BVGWifiRecorder
//
//  Created by Julius Tens on 13.06.19.
//  Copyright © 2019 Julius Tens. All rights reserved.
//

struct ConfigStructure {
    let wifiSsidWhitelist: [String]? = ["BVG Wi-Fi"] // optional, set to nil to deactivate whitelisting
    let endpoint = "https://bvg-wifi-recording.juliustens.eu/" // recordings will be POSTed to this URL

    // UI Text Configuration
    let wifiHeadingText = "WLAN"
    let lineHeadingText = "Linie"
    let stationHeadingText = "Bahnhof"
    let directionHeadingText = "Richtung"

    let pickLineText = "Linie auswählen"
    let pickStationText = "Bahnhof auswählen"
    let pickDirectionText = "Richtung auswählen"
    let pickLineFirstText = "Zuerst Linie auswählen"
    let pickStationFirstText = "Zuerst Bahnhof auswählen"

    let wifiButtonText = "WLAN aktualisieren"
    let sendButtonText = "Senden"

    let requestWaitingText = "⏳ Warten"
    let requestSuccessText = "✅ OK"
    let requestFailureText = "❌ Fehler"
}

let Config = ConfigStructure() // @todo
