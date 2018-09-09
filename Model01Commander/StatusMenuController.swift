//
//  StatusMenuController.swift
//
//  Copyright (c) 2018 Jochen Pfeiffer
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the &quot;Software&quot;), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
