//
//  Button.swift
//  PieControl
//
//  Created by Lubos Lehota on 18/12/2020.
//

import UIKit

class Button: UIButton {
    var tapAction: () -> Void = {}
    var title: String? {
        get { title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        addTarget(self, action: #selector(runAction), for: .touchUpInside)
        backgroundColor = .black
        layer.cornerRadius = 30
        imageEdgeInsets = .init(top: 10, left: 0, bottom: 10, right: 0)
        titleEdgeInsets = .init(top: 10, left: 0, bottom: 10, right: 0)
    }

    @objc func runAction() {
        tapAction()
    }
}
