//
//  TextFieldToolbar.swift
//  PieControl
//
//  Created by Lubos Lehota on 18/12/2020.
//

import UIKit

class TextFieldToolbar: UIToolbar {
    var fields: [UITextField] = [] { didSet { fields.forEach { $0.inputAccessoryView = self }} }

    init() {
        super.init(frame: .zero)

        let closeItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        setItems([spacing, closeItem], animated: false)
        sizeToFit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc func close() {
        fields.forEach { $0.resignFirstResponder() }
    }
}
