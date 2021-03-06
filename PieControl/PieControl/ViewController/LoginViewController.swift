//
//  LoginViewController.swift
//  PieControl
//
//  Created by Lubos Lehota on 18/12/2020.
//

import UIKit

final class LoginViewController: UIViewController {
    private let toolbar = TextFieldToolbar()
    private let keychainController = KeychainAccessController.instance
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: Button!
    @IBOutlet weak var loadFromKeychainButton: Button!

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.tapAction = { [weak self] in self?.login() }
        loadFromKeychainButton.tapAction = { [weak self] in self?.loadFromKeychain() }

        [loadFromKeychainButton, loginButton].forEach {
            $0?.imageView?.contentMode = .scaleAspectFit
            $0?.tintColor = .white
        }
        toolbar.fields = [loginField, passwordField]
    }

    private func loadFromKeychain() {
        keychainController.loadLogin { [weak self] in
            guard let login = $0 else { return }

            self?.launchControls(withLogin: login)
        }
    }

    private func login() {
        guard let login = loginField.text, let password = passwordField.text else { return }
        keychainController.saveLogin(Login(name: login, password: password))
    }

    private func launchControls(withLogin login: Login) {
        let controller = ControlsViewController.instantiateFromMain()
        let sessionController = SessionController(username: login.name, password: login.password)
        controller.sessionController = sessionController

        navigationController?.pushViewController(controller, animated: true)
    }
}
