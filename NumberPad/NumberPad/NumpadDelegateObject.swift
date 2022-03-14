//
//  NumpadDelegateObject.swift
//  NumberPad
//
//  Created by Bogdan Kalchev on 1.03.22.
//

import Foundation
import UIKit

public class NumpadDelegateObject : NSObject, UISearchBarDelegate {
    
    public enum TextFieldInputMode {
        case normal
        case multiTap
    }
    
    var timer: Timer!
    var currentNumberBeingPressed: String = ""
    var accumulatedText: String = ""
    var textInTextField: String = ""
    var timerInAction = false
    
    public var defaultSearchBarButtonClickClosure: (() -> ())? = nil
    public var defaultSearchBarTextDidChangeClosure: ((_ searchText: String) -> ())? = nil
    
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
    
    public var mode: TextFieldInputMode = TextFieldInputMode.normal
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if self.mode == .normal && self.defaultSearchBarButtonClickClosure != nil { // self.mode == .normal, cause .nummpad has no search button
            self.defaultSearchBarButtonClickClosure!()
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.textInTextField = searchText
        self.defaultSearchBarTextDidChangeClosure?(searchText)
    }
    
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        switch(mode) {
            
            case .normal:
                if timer != nil { timer.invalidate() }
                accumulatedText = ""
                timerInAction = false
                currentNumberBeingPressed = ""
                return true
            
            case .multiTap:
                if text.isEmpty { // handling deletion
                    currentNumberBeingPressed = ""
                    
                    if timerInAction {
                        timer.invalidate()
                        self.timerInAction = false
                        self.accumulatedText = ""
                    }
                    
                    return true
                } else {

                    if currentNumberBeingPressed != text {
                        if currentNumberBeingPressed != "" { timer.fire() }
                        currentNumberBeingPressed = text
                    }
                    
                    // from here on - accumulatedText will only contain
                    // the same numbers as string

                    accumulatedText += text
                    print(accumulatedText)
                    
                    let keyPressObject = NumPadKeyPress(fromValue: currentNumberBeingPressed, fromTimesPressed: accumulatedText.count)

                    if let translatedAccumulatedText = multiTapLanguage[keyPressObject.toString()] {
                        if let currentText = searchBar.text {
                            
                            if currentText.isEmpty {
                                searchBar.text = translatedAccumulatedText
                            } else {
                                if timerInAction { searchBar.text!.removeLast() }
                                searchBar.text! += translatedAccumulatedText
                            }
                                                
                        }
                    }
                          
                    if !timerInAction {
                        
                        timer = Timer.scheduledTimer(
                            withTimeInterval: 1.5,
                            repeats: false,
                            block:
                                { timer in
                                print("Timer fired.")
                               
                                self.timerInAction = false

                                print(self.accumulatedText)

                                // create NumPadKeyPress
                                let keyPressObject = NumPadKeyPress(fromValue: self.currentNumberBeingPressed, fromTimesPressed: self.accumulatedText.count)

                                if let translatedAccumulatedText = self.multiTapLanguage[keyPressObject.toString()] {
                                    self.textInTextField += translatedAccumulatedText
                                    self.searchBar(searchBar, textDidChange: self.textInTextField)
                                }
                                
                                self.accumulatedText = ""
                                })
                        
                        timerInAction = true
                    }

                    return false
                }
        }
    }

    public func toggleMode() {
        switch mode {
            case .normal:
                mode = .multiTap
            case .multiTap:
                mode = .normal
        }
    }
}
