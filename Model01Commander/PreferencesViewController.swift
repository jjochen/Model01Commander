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
        super.viewWillDisappear()
        userDefaultsController.save(self)
    }

    fileprivate var selectedPath: String?
    fileprivate var selectedKey: String?
}

extension PreferencesViewController {
    @IBAction func addButtonClicked(_: NSButton) {
        selectPath()
    }

    fileprivate func selectPath() {
        guard let window = view.window else {
            return
        }

        let openPanel = NSOpenPanel()
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications/")
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.title = "Select an Application"

        openPanel.beginSheetModal(for: window) { response in
            if response == .OK {
                self.selectedPath = openPanel.url?.path
                self.selectKey()
            }
            openPanel.close()
        }
    }

    fileprivate func selectKey() {
        guard let textInputViewController = TextInputViewController.loadFromStoryboard() else {
            return
        }
        textInputViewController.delegate = self
        presentViewControllerAsSheet(textInputViewController)
    }

    fileprivate func addSelectedMapping() {
        let object = applicationMappingController.newObject()
        object.key = selectedKey
        object.value = selectedPath
        applicationMappingController.addObject(object)
    }
}

extension PreferencesViewController: TextInputViewControllerDelegate {
    func textInputViewControllerDone(_ controller: TextInputViewController, text: String?) {
        selectedKey = text
        dismissViewController(controller)
        addSelectedMapping()
    }
}

