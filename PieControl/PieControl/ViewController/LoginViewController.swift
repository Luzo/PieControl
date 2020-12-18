//
//  LoginViewController.swift
//  PieControl
//
//  Created by Lubos Lehota on 18/12/2020.
//

import KeychainAccess
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
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let controller = storyboard.instantiateViewController(identifier: ControlsViewController.name)
                as? ControlsViewController else {
            return
        }
        controller.username = login.name
        controller.password = login.password

        navigationController?.pushViewController(controller, animated: true)
    }
}

struct Login {
    let name: String
    let password: String
}

class KeychainAccessController {
    static let instance = KeychainAccessController()
    private let keychain = Keychain(service: "pie.control.passwords")
    private let dataSeparator = ";"
    private let key = "loginData"

    private init() {}

    func loadLogin(completion: @escaping (Login?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            do {
                let loginData = try self.keychain
                    .authenticationPrompt("Authenticate to login to server")
                    .get(self.key)

                guard
                    let components = loginData?.components(separatedBy: self.dataSeparator),
                    components.count == 2
                else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }

                DispatchQueue.main.async {
                    completion(Login(name: components[0], password: components[1]))
                }
            } catch let error {
                // Error handling if needed...
            }
        }
    }

    func saveLogin(_ login: Login) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            do {
                try self.keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                    .set([login.name, login.password].joined(separator: self.dataSeparator), key: self.key)
            } catch let error {
                // Error handling if needed...
            }
        }
    }
}
