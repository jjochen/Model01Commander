//
//  SerialPortController.swift
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

import Foundation
import ORSSerial

protocol SerialPortControllerDelegate: AnyObject {
    func serialPortControllerConnectionDidOpen(_ controller: SerialPortController)
    func serialPortControllerConnectionDidClose(_ controller: SerialPortController)
}

class SerialPortController: NSObject {
    weak var delegate: SerialPortControllerDelegate?

    fileprivate var userNotificationController = UserNotificationController()
    fileprivate var serialPortManager = ORSSerialPortManager()
    fileprivate var serialPort: ORSSerialPort?
    fileprivate var receivedDataString: String?

    override init() {
        super.init()
        initNotifications()
        connect()
    }

    deinit {
        deinitNotifications()
    }
}

extension SerialPortController {
    var isConnected: Bool {
        return serialPort?.isOpen ?? false
    }

    func connect() {
        serialPort = ORSSerialPort(path: Preferences.serialPortPath)
        serialPort?.baudRate = Preferences.serialPortBaudRate
        serialPort?.delegate = self
        serialPort?.dtr = true
        serialPort?.rts = true
        serialPort?.open()
    }

    func disconnect() {
        serialPort?.close()
    }

    func toggleConnection() {
        if isConnected {
            disconnect()
        } else {
            connect()
        }
    }
}

// MARK: - Notifications

extension SerialPortController {
    fileprivate func initNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(serialPortsWereConnected(_:)),
                                       name: NSNotification.Name.ORSSerialPortsWereConnected,
                                       object: nil)
    }

    fileprivate func deinitNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func serialPortsWereConnected(_ notification: Notification) {
        guard let connectedPorts = notification.userInfo?[ORSConnectedSerialPortsKey] as? [ORSSerialPort] else {
            return
        }
        connectedPorts.forEach { port in
            if port.path == Preferences.serialPortPath {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.connect()
                }
                return
            }
        }
    }
}

// MARK: - ORSSerialPortDelegate

extension SerialPortController: ORSSerialPortDelegate {
    func serialPortWasRemoved(fromSystem _: ORSSerialPort) {
        serialPort = nil
    }

    func serialPort(_: ORSSerialPort, didReceive data: Data) {
        handleReceivedData(data)
    }

    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        printStatus("encountered error: \(error)", for: serialPort)
    }

    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        printStatus("was opened", for: serialPort)
        delegate?.serialPortControllerConnectionDidOpen(self)
        postConnectionDidOpenUserNotification()
    }

    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        printStatus("was closed", for: serialPort)
        delegate?.serialPortControllerConnectionDidClose(self)
        postConnectionDidCloseUserNotification()
    }

    fileprivate func printStatus(_ status: String, for serialPort: ORSSerialPort) {
        print("Serial port \(serialPort) (\(serialPort.baudRate)) \(status)")
    }
}

// MARK: - Data Processing

fileprivate extension SerialPortController {
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

        print("Warning: Received data unknown (\(string)).")
    }

    func open(_ app: String) {
        guard let path = Preferences.applicationPath(forKey: app) else {
            print("Warning: App identfier unknown (\(app)).")
            return
        }
        print("Opening \(app) (\(path)) ...")
        postOpenAppUserNotification(forApp: app)

        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", path]
        task.launch()
    }
}

// MARK: - User Notifications

fileprivate extension SerialPortController {
    func postConnectionDidOpenUserNotification() {
        userNotificationController.post(withTitle: "Model01 Connected",
                                        informativeText: "Model01 was connected to your Mac.")
    }

    func postConnectionDidCloseUserNotification() {
        userNotificationController.post(withTitle: "Model01 Disconnected",
                                        informativeText: "Model01 was disconnected from your Mac.")
    }

    func postOpenAppUserNotification(forApp app: String) {
        userNotificationController.post(withTitle: "Model01Commander",
                                        informativeText: "Opening \(app).")
    }
}
