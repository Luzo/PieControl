//
//  ViewController.swift
//  PieControl
//
//  Created by Lubos Lehota on 18/12/2020.
//

import NMSSH
import UIKit

class ControlsViewController: UIViewController {
    var username: String = ""
    var password: String = ""

    @IBOutlet weak var crossImageView: UIImageView!
    @IBOutlet weak var crossScreensaverImageView: UIImageView!
    @IBOutlet weak var connectButton: Button!
    @IBOutlet weak var screensaverButton: Button!
    @IBOutlet weak var netflixButton: Button!
    @IBOutlet weak var resetButton: Button!
    @IBOutlet weak var powerOffButton: Button!

    var screensaverState: Bool = false
    private lazy var session = NMSSHSession(host: "raspberrypi.local", andUsername: username)

    override func viewDidLoad() {
        super.viewDidLoad()

        connectButton.tapAction = { [weak self] in self?.toggleSshConnection() }
        screensaverButton.tapAction = { [weak self] in self?.toggleScreensaver() }
        netflixButton.tapAction = { [weak self] in self?.showNetflix() }
        resetButton.tapAction = { [weak self] in self?.reset() }
        powerOffButton.tapAction = { [weak self] in self?.powerOff() }

        [connectButton, netflixButton, screensaverButton, resetButton, powerOffButton].forEach {
            $0?.imageView?.contentMode = .scaleAspectFit
            $0?.tintColor = .white
        }
        setButtonsForState()
        crossScreensaverImageView.isHidden = true
    }

    func toggleSshConnection() {
        guard !session.isConnected else {
            disconnect()
            return
        }

        session.connect()
        guard session.isConnected else { return }
        session.authenticate(byPassword: password)

        if !session.isAuthorized { disconnect() }

        setButtonsForState()
    }

    private func setButtonsForState() {
        crossImageView.isHidden = !session.isConnected
        screensaverButton.isHidden = !session.isConnected
        netflixButton.isHidden = !session.isConnected
        resetButton.isHidden = !session.isConnected
        powerOffButton.isHidden = !session.isConnected
    }

    private func toggleScreensaver() {
        guard session.isConnected && session.isAuthorized else { return }

        let baseToggleCommand = "xscreensaver-command"
        let stateToToggle = !screensaverState ? "-activate" : "-deactivate"
        var error: NSError?
        session.channel.execute("\(baseToggleCommand) \(stateToToggle)", error: &error)
        screensaverState = !screensaverState
        if error != nil { toggleScreensaver() }
        crossScreensaverImageView.isHidden = !screensaverState
    }

    private func showNetflix() {
        guard session.isConnected && session.isAuthorized else { return }

        let netflixCommand = "nohup sh Desktop/open_browser.sh -u https://www.netflix.com/ >/dev/null 2>&1 &"
        var error: NSError?
        session.channel.execute(netflixCommand, error: &error)
        if error != nil { }
    }

    private func powerOff() {
        guard session.isConnected && session.isAuthorized else { return }

        var error: NSError?
        session.channel.execute("sudo shutdown -h now", error: &error)
        guard error == nil else { return }

        disconnect()
    }

    private func reset() {
        guard session.isConnected && session.isAuthorized else { return }

        var error: NSError?
        session.channel.execute("sudo reboot", error: &error)
        guard error == nil else { return }

        disconnect()
    }

    private func disconnect() {
        session.disconnect()
        setButtonsForState()
    }
}

