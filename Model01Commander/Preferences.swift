//
//  Preferences.swift
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

private enum PreferencesKey: String {
    case serialPortPath
    case serialPortBaudRate
    case applicationMapping
}

private struct DefaultValue {
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
    var store: UserDefaults

    init(store: UserDefaults) {
        self.store = store

        setup()
    }

    func setup() {
        print("Serial Port Path: \(serialPortPath)")
        print("Serial Port Baud Rate: \(serialPortBaudRate)")
        print("Application Mapping: \(applicationMapping)")
    }

    var serialPortPath: String {
        set(value) {
            set(value, forKey: .serialPortPath)
        }
        get {
            return object(forKey: .serialPortPath, defaultValue: DefaultValue.serialPortPath)
        }
    }

    var serialPortBaudRate: NSNumber {
        set(value) {
            set(value, forKey: .serialPortBaudRate)
        }
        get {
            return object(forKey: .serialPortBaudRate, defaultValue: DefaultValue.serialPortBaudRate)
        }
    }

    var applicationMapping: [String: String] {
        set(value) {
            set(value, forKey: .applicationMapping)
        }
        get {
            return object(forKey: .applicationMapping, defaultValue: DefaultValue.appliationMapping)
        }
    }

    func applicationPath(forKey key: String?) -> String? {
        guard let key = key else {
            return nil
        }
        return applicationMapping[key]
    }
}

fileprivate extension Preferences {
    func set(_ value: Any?, forKey key: PreferencesKey) {
        store.set(value, forKey: key.rawValue)
    }

    func object<T>(forKey key: PreferencesKey, defaultValue: T) -> T {
        guard let value = store.object(forKey: key.rawValue) as? T else {
            set(defaultValue, forKey: key)
            return defaultValue
        }
        return value
    }
}
