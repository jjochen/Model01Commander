//
//  AppDelegate.swift
//  Model01Commander
//
//  Created by Jochen on 06.09.18.
//  Copyright © 2018 Jochen Pfeiffer. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
}


extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

fileprivate extension AppDelegate {
    func setupStatusItem() {
        statusItem.button?.image = #imageLiteral(resourceName: "menu_bar_icon_16pt")

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.settingsMenuItemClicked(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Model01 Commander", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
}

fileprivate extension AppDelegate {
    @objc func settingsMenuItemClicked(_ sender: Any?) {
        print("settings menu item clicked")
    }
}
