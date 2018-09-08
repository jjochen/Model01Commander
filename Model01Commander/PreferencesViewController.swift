//
//  PreferencesViewController.swift
//  Model01Commander
//
//  Created by Jochen on 06.09.18.
//  Copyright © 2018 Jochen Pfeiffer. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet var applicationMappingController: NSDictionaryController!
    @IBOutlet var userDefaultsController: NSUserDefaultsController!

    override func viewWillDisappear() {
        userDefaultsController.save(self)
    }
}
