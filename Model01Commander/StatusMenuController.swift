//
//  StatusMenuController.swift
//  Model01Commander
//
//  Created by Jochen on 06.09.18.
//  Copyright © 2018 Jochen Pfeiffer. All rights reserved.
//

import Cocoa
import ORSSerial

class StatusMenuController: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    @IBOutlet var menu: NSMenu!
    @IBOutlet weak var statusMenuItem: NSMenuItem!
    @IBOutlet weak var connectMenuItem: NSMenuItem!

    fileprivate var serialPort: ORSSerialPort?
    fileprivate var receivedDataString: String?

    // todo: move to dynamic settings
    fileprivate let appMapping = [
        "calendar": "/Applications/Calendar.app",
        "chat": "/Applications/HipChat.app",
        "browser": "/Applications/Google Chrome.app",
        "terminal": "/Applications/iTerm.app",
        "music": "/Applications/iTunes.app",
        "diff": "/Applications/SourceTree.app",
        "xcode": "/Applications/Xcode.app",
        "guide": "/Users/jochen/coden/esanum/ios/MEG.xcworkspace",
        ]


    override init() {
        super.init()
        registerForNotifications()
        NSUserNotificationCenter.default.delegate = self
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func awakeFromNib() {
        setupMenu()
        connectToSerialPort()
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
        let status = serialPortConnected ? "connected" : "disconnected"
        statusMenuItem.title = "Model01: \(status)"
        connectMenuItem.title = serialPortConnected ? "Disconnect" : "Connect"
    }
}

fileprivate extension StatusMenuController {
    @IBAction func connectItemClicked(_ sender: NSMenuItem) {
        print("Connect menu item clicked")
        toggleSerialPortConnection()
    }

    @IBAction func preferencesClicked(_: NSMenuItem) {
        print("Preferences menu item clicked")
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(sender)
    }
}

// MARK: - Serial Port

fileprivate extension StatusMenuController {
    var serialPortConnected: Bool {
        return serialPort?.isOpen ?? false
    }

    func connectToSerialPort() {
        // todo: move path and baud rate to settings
        serialPort = ORSSerialPort(path: "/dev/cu.usbmodemCkbio011")
        serialPort?.baudRate = 9600
        serialPort?.delegate = self
        serialPort?.dtr = true
        serialPort?.rts = true
        serialPort?.open()
    }

    func disconnectFromSerialPort() {
        serialPort?.close()
    }

    func toggleSerialPortConnection() {
        if serialPortConnected {
            disconnectFromSerialPort()
        } else {
            connectToSerialPort()
        }
    }
}

// MARK: - ORSSerialPortDelegate

extension StatusMenuController: ORSSerialPortDelegate {

    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        self.serialPort = nil
        updateMenu()
    }

    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        handleReceivedData(data)
    }

    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        printStatus("encountered error: \(error)", for: serialPort)
    }

    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        printStatus("was opened", for: serialPort)
        postUserNotification(serialPortOpened: true)
        updateMenu()
    }

    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        printStatus("was closed", for: serialPort)
        postUserNotification(serialPortOpened: false)
        updateMenu()
    }

    fileprivate func printStatus(_ status: String, for serialPort: ORSSerialPort) {
        print("Serial port \(serialPort) (\(serialPort.baudRate)) \(status)")
    }
}

// MARK: - Data Processing

fileprivate extension StatusMenuController {
    func handleReceivedData(_ receivedData: Data) {
        appendReceivedData(receivedData)
        handleCurrentReceivedDataString()
    }

    func appendReceivedData(_ receivedData: Data) {
        guard let string = NSString(data: receivedData, encoding: String.Encoding.utf8.rawValue) as String? else {
            print("Warning: Received data not a string.")
            return
        }

        if receivedDataString == nil {
            receivedDataString = ""
        }

        receivedDataString?.append(string)
    }

    func handleCurrentReceivedDataString() {
        guard var string = receivedDataString else {
            return
        }

        let lineEnding = "\r\n"
        guard string.hasSuffix(lineEnding) else {
            return
        }
        string = String(string.dropLast(lineEnding.count))

        receivedDataString = nil

        let appPrefix = "APP:"
        if string.hasPrefix(appPrefix) {
            let app = String(string.dropFirst(appPrefix.count))
            open(app)
            return
        }

        print("Warning: Couldn't interpret received data (\(string)).")
    }

    func open(_ app: String) {
        guard app.count > 0 else {
            print("Warning: No app identifier.")
            return
        }
        guard let path = appMapping[app.lowercased()] else {
            print("Warning: No mapping for app identfier (\(app)).")
            return
        }
        print("Opening \(app) (\(path)) ...")
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", path]
        task.launch()
    }
}

// MARK: - NSUserNotifcationCenterDelegate

extension StatusMenuController: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        let popTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
            center.removeDeliveredNotification(notification)
        }
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }

    fileprivate func postUserNotification(serialPortOpened opened: Bool) {
        if opened {
            postUserNotification(withTitle: "Model01 Connected",
                                 informativeText: "Model01 was connected to your Mac.")
        } else {
            postUserNotification(withTitle: "Model01 Disconnected",
                                 informativeText: "Model01 was disconnected from your Mac.")
        }
    }

    fileprivate func postUserNotification(withTitle title: String, informativeText: String) {
        let userNotificationCenter = NSUserNotificationCenter.default
        let userNotification = NSUserNotification()
        userNotification.title = title
        userNotification.informativeText = informativeText
        userNotification.soundName = nil;
        userNotificationCenter.deliver(userNotification)
    }
}

// MARK: - Notifications

extension StatusMenuController {
    fileprivate func registerForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(serialPortsWereConnected(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
        notificationCenter.addObserver(self, selector: #selector(serialPortsWereDisconnected(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
    }

    @objc func serialPortsWereConnected(_ notification: Notification) {
        guard let connectedPorts = notification.userInfo?[ORSConnectedSerialPortsKey] as? [ORSSerialPort] else {
            return
        }
        print("Ports were connected: \(connectedPorts)")
        // todo
    }

    @objc func serialPortsWereDisconnected(_ notification: Notification) {
        guard let disconnectedPorts = notification.userInfo?[ORSDisconnectedSerialPortsKey] as? [ORSSerialPort] else {
            return
        }
        print("Ports were disconnected: \(disconnectedPorts)")
        // todo
    }
}

