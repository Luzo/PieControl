//
//  ViewController.swift
//  PieControl
//
//  Created by Lubos Lehota on 18/12/2020.
//

import NMSSH
import UIKit

class ControlsViewController: UIViewController {
    @IBOutlet weak var crossImageView: UIImageView!
    @IBOutlet weak var crossScreensaverImageView: UIImageView!
    @IBOutlet weak var crossAirplayImageView: UIImageView!
    @IBOutlet weak var connectButton: Button!
    @IBOutlet weak var screensaverButton: Button!
    @IBOutlet weak var airplayButton: Button!
    @IBOutlet weak var netflixButton: Button!
    @IBOutlet weak var resetButton: Button!
    @IBOutlet weak var powerOffButton: Button!

    private var screensaverState: Bool = false
    private var airplayState: Bool = false

    var sessionController: SessionController!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtonConnections()
        [connectButton, netflixButton, screensaverButton, airplayButton, resetButton, powerOffButton].forEach {
            $0?.imageView?.contentMode = .scaleAspectFit
            $0?.tintColor = .white
        }
        setButtonsForState()
        crossScreensaverImageView.isHidden = true
        crossAirplayImageView.isHidden = true
        sessionController.sessionChangeEventBlock = { [weak self] in self?.setButtonsForState() }
    }

    private func setupButtonConnections() {
        connectButton.tapAction = { [weak self] in self?.sessionController.toggleConnection() }
        screensaverButton.tapAction = { [weak self] in self?.toggleScreensaver() }
        netflixButton.tapAction = { [weak self] in self?.showNetflix() }
        airplayButton.tapAction = { [weak self] in self?.toggleAirplay() }
        resetButton.tapAction = { [weak self] in self?.reset() }
        powerOffButton.tapAction = { [weak self] in self?.powerOff() }
    }

    private func setButtonsForState() {
        crossImageView.isHidden = !sessionController.hasConnectedSession
        screensaverButton.isHidden = !sessionController.hasConnectedSession
        netflixButton.isHidden = !sessionController.hasConnectedSession
        resetButton.isHidden = !sessionController.hasConnectedSession
        powerOffButton.isHidden = !sessionController.hasConnectedSession
        airplayButton.isHidden = !sessionController.hasConnectedSession

        if !sessionController.hasConnectedSession {
            screensaverState = false
            airplayState = false
        }
        crossScreensaverImageView.isHidden = !screensaverState
        crossAirplayImageView.isHidden = !airplayState
    }

    private func toggleScreensaver() {
        let baseToggleCommand = "xscreensaver-command"
        let stateToToggle = !screensaverState ? "-activate" : "-deactivate"

        if sessionController.executeCommand("\(baseToggleCommand) \(stateToToggle)") {
            screensaverState = !screensaverState
            setButtonsForState()
        } else {
            toggleScreensaver()
        }
    }

    private func showNetflix() {
        sessionController.executeCommand("sh ~/Tools/Scripts/open_browser.sh -u https://www.netflix.com/")
    }

    private func toggleAirplay() {
        let airplayCommand = "sh ~/Tools/Scripts/start_airplay.sh"
        let killCommand = "pkill -f start_airplay\\|rpiplay"
        if sessionController.executeCommand(airplayState ? killCommand : airplayCommand) {
            airplayState = !airplayState
            setButtonsForState()
        }
    }

    private func powerOff() { sessionController.executeCommand("sudo shutdown -h now") }

    private func reset() { sessionController.executeCommand("sudo reboot") }
}

