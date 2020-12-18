//
//  UIViewController+Utils.swift
//  PieControl
//
//  Created by Lubos Lehota on 18/12/2020.
//

import UIKit

extension UIViewController {
    static var name: String { return String(describing: self) }

    static func instantiateFromMain() -> Self {
        guard let controller = UIStoryboard.main.instantiateViewController(identifier: Self.name) as? Self else {
            fatalError()
        }

        return controller
    }
}
