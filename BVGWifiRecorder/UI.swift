//
//  Picker.swift
//  BVGWifiRecorder
//
//  Created by Julius Tens on 12.06.19.
//  Copyright © 2019 Julius Tens. All rights reserved.
//

import UIKit

func createHeading(text: String) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = text
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.numberOfLines = 0 // infinite
    label.font = .boldSystemFont(ofSize: 30)
    label.sizeToFit()
    label.textAlignment = .left
    return label
}

func createLabel(text: String) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = text
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.numberOfLines = 0 // infinite
    label.font = .systemFont(ofSize: 22.5)
    label.textColor = UIColor.gray
    label.sizeToFit()
    label.textAlignment = .left
    return label
}

func createTextField(label: String?) -> UITextField {
    let textField = UITextField()
    textField.font = .systemFont(ofSize: 22.5)
    textField.textColor = UIColor.gray
    textField.text = label
    textField.tintColor = .clear
    return textField
}

func createButton(title: String, color: UIColor, enabled: Bool) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    button.backgroundColor = color
    button.titleLabel?.font = .boldSystemFont(ofSize: 20)
    button.layer.cornerRadius = 10
    button.isHidden = false
    button.isEnabled = enabled
    return button
}

func ssidText(_ wifi: WifiInformation?) -> String {
    return "SSID: \(wifi?.ssid ?? "-")"
}

func bssidText(_ wifi: WifiInformation?) -> String {
    return "BSSID: \(wifi?.bssid ?? "-")"
}

// Picker

struct PickerValue {
    let id: String
    let label: String
}

class PickerViewDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    var data: [PickerValue] = []
    var onPick: ((_ picked: PickerValue) -> Void)?

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row].label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.onPick?(data[row])
    }
}
