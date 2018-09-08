//
//  Preferences.swift
//  Model01Commander
//
//  Created by Jochen on 08.09.18.
//  Copyright © 2018 Jochen Pfeiffer. All rights reserved.
//

import Foundation

fileprivate enum PreferencesKey: String {
    case serialPortPath
    case serialPortBaudRate
    case applicationMapping
}

fileprivate struct DefaultValue {
    static var serialPortPath: String {
        return "/dev/cu.usbmodemCkbio011"
    }

    static var serialPortBaudRate: NSNumber {
        return 9600
    }

    static var appliationMapping: [String: String] {
        return [
            "browser": "/Applications/Google Chrome.app",
            "calendar": "/Applications/Calendar.app",
            "chat": "/Applications/HipChat.app",
            "diff": "/Applications/SourceTree.app",
            "music": "/Applications/iTunes.app",
            "terminal": "/Applications/iTerm.app",
            "xcode": "/Applications/Xcode.app",
        ]
    }
}

class Preferences {
    static func setup() {
        print("Serial Port Path: \(serialPortPath)")
        print("Serial Port Baud Rate: \(serialPortBaudRate)")
        print("Application Mapping: \(applicationMapping)")
    }

    static func safe() {
        userDefaults.synchronize()
    }

    static var serialPortPath: String {
        set(value) {
            set(value, forKey: .serialPortPath)
        }
        get {
            return object(forKey: .serialPortPath, defaultValue: DefaultValue.serialPortPath)
        }
    }

    static var serialPortBaudRate: NSNumber {
        set(value) {
            set(value, forKey: .serialPortBaudRate)
        }
        get {
            return object(forKey: .serialPortBaudRate, defaultValue: DefaultValue.serialPortBaudRate)
        }
    }

    static var applicationMapping: [String: String] {
        set(value) {
            set(value, forKey: .applicationMapping)
        }
        get {
            return object(forKey: .applicationMapping, defaultValue: DefaultValue.appliationMapping)
        }
    }

    static func applicationPath(forKey key: String?) -> String? {
        guard let key = key else {
            return nil
        }
        return applicationMapping[key]
    }
}

fileprivate extension Preferences {
    static var userDefaults: UserDefaults {
        return UserDefaults.standard
    }

    static func set(_ value: Any?, forKey key: PreferencesKey) {
        userDefaults.set(value, forKey: key.rawValue)
    }

    static func object<T>(forKey key: PreferencesKey, defaultValue: T) -> T {
        guard let value = userDefaults.object(forKey: key.rawValue) as? T else {
            set(defaultValue, forKey: key)
            return defaultValue
        }
        return value
    }
}

