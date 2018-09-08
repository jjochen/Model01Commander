//
//  StatusMenuController.swift
//  Model01Commander
//
//  Created by Jochen on 06.09.18.
//  Copyright © 2018 Jochen Pfeiffer. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    @IBOutlet var menu: NSMenu!
    @IBOutlet var statusMenuItem: NSMenuItem!
    @IBOutlet var connectMenuItem: NSMenuItem!

    fileprivate var serialPortController: SerialPortController {
        let serialPortController = SerialPortController()
        serialPortController.delegate = self
        return serialPortController
    }

    override func awakeFromNib() {
        setupMenu()
    }
}

// MARK: - Status Menu

fileprivate extension StatusMenuController {
    func setupMenu() {
        statusItem.button?.image = #imageLiteral(resourceName: "status_menu_item_16pt")
        statusItem.menu = menu
        updateMenu()
    }

    func updateMenu() {
        let status = serialPortController.isConnected ? "connected" : "disconnected"
        statusMenuItem.title = "Model01: \(status)"
        connectMenuItem.title = serialPortController.isConnected ? "Disconnect" : "Connect"
    }
}

fileprivate extension StatusMenuController {
    @IBAction func connectItemClicked(_: NSMenuItem) {
        serialPortController.toggleConnection()
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(sender)
    }
}

// MARK: - SerialPortControllerDelegate

extension StatusMenuController: SerialPortControllerDelegate {
    func serialPortControllerConnectionDidOpen(_: SerialPortController) {
        updateMenu()
    }

    func serialPortControllerConnectionDidClose(_: SerialPortController) {
        updateMenu()
    }
}
