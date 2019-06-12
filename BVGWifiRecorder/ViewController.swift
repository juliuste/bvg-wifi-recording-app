//
//  ViewController.swift
//  BVGWifiRecorder
//
//  Created by Julius Tens on 04.06.19.
//  Copyright © 2019 Julius Tens. All rights reserved.
//

import UIKit

// parse stations, @todo request from server
let url = Bundle.main.url(forResource: "stations", withExtension: "json")
let data = NSData(contentsOf: url!)
let stations = try! JSONDecoder().decode([Station].self, from: (data! as Data))

class ViewController: UIViewController {
    private var recording = Recording(wifi: nil, line: nil, station: nil, direction: nil)

    private let wifiHeading = createHeading(text: Config.wifiHeadingText)
    private let lineHeading = createHeading(text: Config.lineHeadingText)
    private let stationHeading = createHeading(text: Config.stationHeadingText)
    private let directionHeading = createHeading(text: Config.directionHeadingText)

    private let ssidLabel = createLabel(text: ssidText(nil))
    private let bssidLabel = createLabel(text: bssidText(nil))

    private let lineTextField = createTextField(label: Config.pickLineText)
    private let linePicker = UIPickerView()
    private let linePickerDelegate = PickerViewDelegate()

    private let stationTextField = createTextField(label: Config.pickLineFirstText)
    private let stationPicker = UIPickerView()
    private let stationPickerDelegate = PickerViewDelegate()

    private let directionTextField = createTextField(label: Config.pickLineFirstText)
    private let directionPicker = UIPickerView()
    private let directionPickerDelegate = PickerViewDelegate()

    private let wifiButton = createButton(title: Config.wifiButtonText, color: .blue, enabled: true)
    private let sendButton = createButton(title: Config.sendButtonText, color: .lightGray, enabled: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.stopEditing))
        view.addGestureRecognizer(tap)

        linePicker.delegate = linePickerDelegate
        linePicker.dataSource = linePickerDelegate
        linePickerDelegate.data = Array(Set(stations.map({ station in station.line }))).sorted().map({ line in PickerValue(id: line, label: line) })
        linePickerDelegate.onPick = self.onLinePick
        lineTextField.inputView = linePicker

        stationPicker.delegate = stationPickerDelegate
        stationPicker.dataSource = stationPickerDelegate
        stationPickerDelegate.data = []
        stationPickerDelegate.onPick = self.onStationPick
        stationTextField.inputView = stationPicker

        directionPicker.delegate = directionPickerDelegate
        directionPicker.dataSource = directionPickerDelegate
        directionPickerDelegate.data = []
        directionPickerDelegate.onPick = self.onDirectionPick
        directionTextField.inputView = directionPicker

        let stackView = UIStackView(arrangedSubviews: [
            wifiHeading,
            ssidLabel,
            bssidLabel,
            lineHeading,
            lineTextField,
            stationHeading,
            stationTextField,
            directionHeading,
            directionTextField,
            wifiButton,
            sendButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.setCustomSpacing(15, after: bssidLabel)
        stackView.setCustomSpacing(15, after: lineTextField)
        stackView.setCustomSpacing(15, after: stationTextField)
        stackView.setCustomSpacing(30, after: directionTextField)
        stackView.setCustomSpacing(15, after: wifiButton)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delaysContentTouches = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: CGFloat(16)),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: CGFloat(16)),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.centerYAnchor.constraint(greaterThanOrEqualTo: scrollView.centerYAnchor)
        ])

        wifiButton.addTarget(self, action: #selector(updateWiFiInformation), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendData), for: .touchUpInside)
    }

    func enableSendButton() {
        sendButton.isEnabled = true
        sendButton.backgroundColor = .gray
    }

    func disableSendButton() {
        sendButton.isEnabled = false
        sendButton.backgroundColor = .lightGray
    }

    func onRecordingChange() {
        ssidLabel.text = ssidText(recording.wifi)
        bssidLabel.text = bssidText(recording.wifi)

        if (recordingIsComplete(recording)) {
            self.enableSendButton()
        } else {
            self.disableSendButton()
        }
    }

    func onLinePick(picked: PickerValue) {
        lineTextField.text = picked.label
        recording.line = picked.id
        stationTextField.text = Config.pickStationText
        recording.station = nil
        stationPickerDelegate.data = stations.filter({ station in station.line == picked.id }).map({ station in PickerValue(id: station.id, label: station.name)}).sorted(by: { $0.label < $1.label })
        directionTextField.text = Config.pickStationFirstText
        recording.direction = nil
        directionPickerDelegate.data = []
        self.onRecordingChange()
    }

    func onStationPick(picked: PickerValue) {
        stationTextField.text = picked.label
        recording.station = picked.id
        directionTextField.text = Config.pickDirectionText
        recording.direction = nil
        directionPickerDelegate.data = stations.first(where: { station in station.id == picked.id })!.neighbors.map({ neighbor in PickerValue(id: neighbor.id, label: neighbor.name) }).sorted(by: { $0.label < $1.label })
        self.onRecordingChange()
    }

    func onDirectionPick(picked: PickerValue) {
        directionTextField.text = picked.label
        recording.direction = picked.id
        self.onRecordingChange()
    }

    @objc func updateWiFiInformation() {
        recording.wifi = currentWifiInformation()
        self.onRecordingChange()
    }

    @objc func sendData() {
        self.disableSendButton()
        self.sendButton.setTitle(Config.requestWaitingText, for: .normal)
        sendRecording(recording: recording, onSuccess: self.onRequestSuccess, onFailure: self.onRequestFailure)
    }

    func onRequestSuccess() {
        sendButton.setTitle(Config.requestSuccessText, for: .normal)
        recording.direction = nil
        directionPickerDelegate.data = []
        recording.wifi = nil
        self.onRecordingChange()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.sendButton.setTitle(Config.sendButtonText, for: .normal)
        }
    }

    func onRequestFailure() {
        sendButton.setTitle(Config.requestFailureText, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.sendButton.setTitle(Config.sendButtonText, for: .normal)
            self.enableSendButton()
        }
    }

    @objc func stopEditing() {
        view.endEditing(true)
    }
}
