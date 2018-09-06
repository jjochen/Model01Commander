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

    override func awakeFromNib() {
        setup()
    }
}

fileprivate extension StatusMenuController {
    func setup() {
        statusItem.button?.image = #imageLiteral(resourceName: "status_menu_item_16pt")
        statusItem.menu = menu
    }
}

fileprivate extension StatusMenuController {
    @IBAction func preferencesClicked(_: NSMenuItem) {
        print("Preferences menu item clicked")
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(sender)
    }
}
