//
//  AppDelegate.swift
//  Model01Commander
//
//  Created by Jochen on 06.09.18.
//  Copyright © 2018 Jochen Pfeiffer. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let serialPortController = SerialPortController()

    func applicationDidFinishLaunching(_: Notification) {
        serialPortController.connect()
    }

    func applicationWillTerminate(_: Notification) {}
}
