//
//  KeychainAccesController.swift
//  PieControl
//
//  Created by Lubos Lehota on 18/12/2020.
//

import KeychainAccess

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
