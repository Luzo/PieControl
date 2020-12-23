//
//  SessionController.swift
//  PieControl
//
//  Created by Lubos Lehota on 23/12/2020.
//

import NMSSH

class SessionController {
    private lazy var session = NMSSHSession(host: "raspberrypi.local", andUsername: username)
    private let username: String
    private let password: String
    var sessionChangeEventBlock: () -> Void = {}
    var hasConnectedSession: Bool { session.isConnected && session.isAuthorized }

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    func toggleConnection() {
        guard !session.isConnected else {
            disconnect()
            return
        }

        session.connect()
        guard session.isConnected else { return }
        session.authenticate(byPassword: password)

        if !session.isAuthorized { disconnect() }

        sessionChangeEventBlock()
    }

    func disconnect() {
        session.disconnect()
        sessionChangeEventBlock()
    }

    @discardableResult
    func executeCommand(_ command: String) -> Bool {
        guard hasConnectedSession else { return false }

        var error: NSError?
        session.channel.execute("nohup \(command) >/dev/null 2>&1 &", error: &error)
        guard error == nil else { return false }

        return true
    }
}
