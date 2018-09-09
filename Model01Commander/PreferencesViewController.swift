//
//  PreferencesViewController.swift
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

