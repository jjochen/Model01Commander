//
//  model01_commander
//
//  Created by Jochen on 26.04.18.
//  Copyright © 2018 Jochen Pfeiffer. All rights reserved.
//

import ORSSerial

class SerialPortController: NSObject {
    var serialPort: ORSSerialPort?

    // todo: move to dynamic settings
    fileprivate let appMapping = [
        "calendar": "/Applications/Calendar.app",
        "chat": "/Applications/HipChat.app",
        "browser": "/Applications/Google Chrome.app",
        "terminal": "/Applications/iTerm.app",
        "music": "/Applications/iTunes.app",
        "diff": "/Applications/SourceTree.app",
        "xcode": "/Applications/Xcode.app",
    ]
}

extension SerialPortController {
    func connect() {
        // todo: move to dynamic settings
        serialPort = ORSSerialPort(path: "/dev/cu.usbmodemCkbio011")
        serialPort?.baudRate = 9600
        serialPort?.delegate = self
        serialPort?.dtr = true
        serialPort?.rts = true
        serialPort?.open()
    }
}

// MARK: - ORSSerialPortDelegate

extension SerialPortController: ORSSerialPortDelegate {
    func serialPortWasRemoved(fromSystem serialPort: ORSSerialPort) {
        self.serialPort = nil
    }

    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        handleReceivedData(data)
    }

    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port (\(serialPort)) encountered error: \(error)")
    }

    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("Serial port \(serialPort) (\(serialPort.baudRate)) was opened")
    }
}

// MARK: - Data Processing

extension SerialPortController {
    func handleReceivedData(_ receivedData: Data) {
        guard let string = NSString(data: receivedData, encoding: String.Encoding.utf8.rawValue) as String? else {
            return
        }

        let appPrefix = "APP:"
        if string.hasPrefix(appPrefix) {
            let app = String(string.dropFirst(appPrefix.count)).replacingOccurrences(of: "\r\n", with: "").trimmingCharacters(in: .whitespaces)
            open(app)
            return
        }
    }
}

// MARK: - Helper

extension SerialPortController {
    func open(_ app: String) {
        guard app.count > 0 else {
            return
        }
        guard let path = appMapping[app.lowercased()] else {
            return
        }
        print("Opening \(app) (\(path)) ...")
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", path]
        task.launch()
    }
}
