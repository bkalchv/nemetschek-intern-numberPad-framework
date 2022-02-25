//
//  File.swift
//  NumberPad
//
//  Created by Bogdan Kalchev on 22.02.22.
//

import Foundation
import UIKit

class CustomTextField : UITextField, UITextInputDelegate, UITextFieldDelegate {
    
    var timer = Timer()
    var currentNumberBeingPressed: String = ""
    var accumulatedText: String = ""
    var textInTextField: String = ""
    var timerInAction = false
    
    let multiTapLanguage = [
        "2"     : "A",
        "22"    : "B",
        "222"   : "C",
        "3"     : "D",
        "33"    : "E",
        "333"   : "F",
        "4"     : "G",
        "44"    : "H",
        "444"   : "I",
        "5"     : "J",
        "55"    : "K",
        "555"   : "L",
        "6"     : "M",
        "66"    : "N",
        "666"   : "O",
        "7"     : "P",
        "77"    : "Q",
        "777"   : "R",
        "7777"  : "S",
        "8"     : "T",
        "88"    : "U",
        "888"   : "V",
        "9"     : "W",
        "99"    : "X",
        "999"   : "Y",
        "9999"  : "Z"
    ]
    
    func selectionWillChange(_ textInput: UITextInput?) {

    }

    func selectionDidChange(_ textInput: UITextInput?) {

    }

    func textWillChange(_ textInput: UITextInput?) {
        print("TextWillChange called")
    }

    func textDidChange(_ textInput: UITextInput?) {
        print("TextDidChange called")
    }
    
    private func setupTextField() {
        layer.cornerRadius = 5
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1.0
        self.keyboardType = UIKeyboardType.asciiCapableNumberPad
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        setupTextField()
        self.delegate = self
        self.inputDelegate = self

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { // handling deletion
            
            if !textInTextField.isEmpty && !timerInAction {
                textInTextField.removeLast()
                self.text = textInTextField
                return false
            }

            currentNumberBeingPressed = ""
            return true

        } else {

            if currentNumberBeingPressed != string {
                if currentNumberBeingPressed != "" { timer.fire() }
                currentNumberBeingPressed = string
            }
            
            // from here on - accumulatedText will only contain
            // the same numbers as string

            accumulatedText += string
            print(accumulatedText)
            
            let keyPressObject = NumPadKeyPress(fromValue: currentNumberBeingPressed, fromTimesPressed: accumulatedText.count)

            if let translatedAccumulatedText = multiTapLanguage[keyPressObject.toString()] {
                if let currentText = self.text {
                    
                    if currentText.isEmpty {
                        self.text = translatedAccumulatedText
                    } else {
                        if timerInAction { self.text!.removeLast() }
                        self.text! += translatedAccumulatedText
                    }
                                        
                }
            }
                  
            if !timerInAction {
                timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
                timerInAction = true
            }

            return false
        }
    }

    @objc func timerAction() {
        print("Timer fired.")
        //print("I will change what your textfield will contain.")
        timerInAction = false

        print(accumulatedText)

        // create NumPadKeyPress
        let keyPressObject = NumPadKeyPress(fromValue: currentNumberBeingPressed, fromTimesPressed: accumulatedText.count)

        if let translatedAccumulatedText = multiTapLanguage[keyPressObject.toString()] {
            textInTextField += translatedAccumulatedText
            self.text = textInTextField
        }
        
        accumulatedText = ""
    }

}
