//
//  PreferencesSpec.swift
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

@testable import Model01Commander
import Nimble
import Quick

class PreferencesSpec: QuickSpec {
    override func spec() {
        describe("Preferences") {
            var preferences: Preferences!

            beforeEach {
                let mockUserDefaults = MockUserDefaults()
                preferences = Preferences(store: mockUserDefaults)
            }

            it("returns a default value for serialPortPath") {
                expect(preferences.serialPortPath).notTo(beNil())
            }

            it("returns stored value for serialPortPath") {
                let value = "new value"
                preferences.serialPortPath = value
                expect(preferences.serialPortPath) == value
            }

            it("returns a default value for serialPortBaudRate") {
                expect(preferences.serialPortBaudRate).notTo(beNil())
            }

            it("returns stored value for serialPortBaudRate") {
                let value: NSNumber = 42
                preferences.serialPortBaudRate = value
                expect(preferences.serialPortBaudRate) == value
            }

            it("returns a default value for applicationMapping") {
                expect(preferences.applicationMapping).notTo(beNil())
            }

            it("returns stored value for applicationMapping") {
                let value = [
                    "browser": "/Applications/Google Chrome.app",
                    "calendar": "/Applications/Calendar.app",
                ]
                preferences.applicationMapping = value
                expect(preferences.applicationMapping) == value
            }
        }
    }
}
