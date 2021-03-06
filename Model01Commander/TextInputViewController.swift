//
//  TextInputViewController.swift
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

protocol TextInputViewControllerDelegate: AnyObject {
    func textInputViewControllerDone(_ controller: TextInputViewController, text: String?)
}

class TextInputViewController: NSViewController {
    weak var delegate: TextInputViewControllerDelegate?

    @IBOutlet var label: NSTextField!
    @IBOutlet var textField: NSTextField!

    @IBAction func doneButtonClicked(_: NSButton) {
        done()
    }

    fileprivate func done() {
        delegate?.textInputViewControllerDone(self, text: textField.cell?.title)
    }
}

extension TextInputViewController {
    static func loadFromStoryboard() -> TextInputViewController? {
        let storyboardName = NSStoryboard.Name(rawValue: "Main")
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
        let sceneIdentifier = NSStoryboard.SceneIdentifier(rawValue: "textInputViewController")
        let controller = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? TextInputViewController
        return controller
    }
}
