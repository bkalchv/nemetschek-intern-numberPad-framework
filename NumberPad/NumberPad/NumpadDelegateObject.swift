//
//  NumpadDelegateObject.swift
//  NumberPad
//
//  Created by Bogdan Kalchev on 1.03.22.
//

import Foundation
import UIKit

public class NumpadDelegateObject : NSObject, UISearchBarDelegate {
    
    public enum SearchBarInputMode {
        case normal
        case multiTap
    }
        
    var timer: Timer!
    var currentNumberBeingPressed: String = ""
    var accumulatedText: String = ""
    var textInTextField: String = ""
    var timerInAction = false
    var wasTextPastedInSearchBar = false
    
    var defaultSearchBarButtonClickClosure: (() -> ())? = nil
    var defaultSearchBarTextDidChangeClosure: ((_ searchText: String) -> ())? = nil
    
    // update multitapCurrentLanguage on Language Change
    var currentMultiTapLanguage: [String:String]? = nil
    
    public var mode: SearchBarInputMode = SearchBarInputMode.normal
    public var multitapLanguage: MultiTapLanguageMode = MultiTapLanguageMode.english
    
    public func setCurrentMultitapLanguage(multitapLanguageDictionary: [String:String]) {
        currentMultiTapLanguage = multitapLanguageDictionary
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.defaultSearchBarButtonClickClosure?()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.textInTextField = searchText
        
        if self.wasTextPastedInSearchBar {
            self.searchBarSearchButtonClicked(searchBar)
            self.wasTextPastedInSearchBar = false
            return
        }
        
        self.defaultSearchBarTextDidChangeClosure?(searchText)
    }
    
    public func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        if text.count > 1 && !self.wasTextPastedInSearchBar {
            self.wasTextPastedInSearchBar = true
            print("paste caught")
            return true
        }
        
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
                    
                    let keyPressObject = NumPadKeyPress(fromValue: currentNumberBeingPressed, fromTimesPressed: accumulatedText.count, forMultitapLanguageMode: multitapLanguage)

                    if let currentMultiTapLanguage = currentMultiTapLanguage, let translatedAccumulatedText = currentMultiTapLanguage[keyPressObject.toString()] {
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
                                    let keyPressObject = NumPadKeyPress(fromValue: self.currentNumberBeingPressed, fromTimesPressed: self.accumulatedText.count, forMultitapLanguageMode: self.multitapLanguage)

                                    if let currentMultiTapLanguage = self.currentMultiTapLanguage, let translatedAccumulatedText = currentMultiTapLanguage[keyPressObject.toString()] {
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
    
    public func toggleMultitapLanguage() {
        switch multitapLanguage {
            case .english:
                multitapLanguage = .bulgarian
            case .bulgarian:
                multitapLanguage = .english
        }
    }
}
