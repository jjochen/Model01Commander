//
//  TextInputViewController.swift
//  Model01Commander
//
//  Created by Jochen on 08.09.18.
//  Copyright © 2018 Jochen Pfeiffer. All rights reserved.
//

import Cocoa

protocol TextInputViewControllerDelegate: AnyObject {
    func textInputViewControllerDone(_ controller: TextInputViewController, text: String?)
}

class TextInputViewController: NSViewController {
    weak var delegate: TextInputViewControllerDelegate?

    @IBOutlet var label: NSTextField!
    @IBOutlet var textField: NSTextField!

    @IBAction func doneButtonClicked(_ sender: NSButton) {
        done()
    }

    fileprivate func done() {
        delegate?.textInputViewControllerDone(self, text: textField.cell?.title)
    }
}

extension TextInputViewController {
    static func loadFromStoryboard() -> TextInputViewController? {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "textInputViewController")) as? TextInputViewController
        return controller
    }
}



