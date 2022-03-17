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
    
    static let multitapLanguageEnglish = [
        "0"     : " ",
        "1"     : "-",
        "11"    : ".",
        "111"   : ",",
        "1111"  : "!",
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
    
    static let multitapLanguageBulgarian = [
        "0"     : " ",
        "1"     : "-",
        "11"    : ".",
        "111"   : ",",
        "1111"  : "!",
        "2"     : "А",
        "22"    : "Б",
        "222"   : "В",
        "2222"  : "Г",
        "3"     : "Д",
        "33"    : "Е",
        "333"   : "Ж",
        "3333"  : "З",
        "4"     : "И",
        "44"    : "Й",
        "444"   : "К",
        "4444"  : "Л",
        "5"     : "М",
        "55"    : "Н",
        "555"   : "О",
        "5555"  : "П",
        "6"     : "Р",
        "66"    : "С",
        "666"   : "Т",
        "6666"  : "У",
        "7"     : "Ф",
        "77"    : "Х",
        "777"   : "Ц",
        "7777"  : "Ч",
        "8"     : "Ш",
        "88"    : "Щ",
        "888"   : "Ъ",
        "8888"  : "ь",
        "9"     : "Ь",
        "99"    : "Э",
        "999"   : "Ю",
        "9999"  : "Я"
    ]
        
    var timer: Timer!
    var currentNumberBeingPressed: String = ""
    var accumulatedText: String = ""
    var textInTextField: String = ""
    var timerInAction = false
    var wasTextPastedInSearchBar = false
    var currentMultitapLanguageDictionary: [String:String]? = nil
    public var mode: SearchBarInputMode = SearchBarInputMode.normal
    public var multitapLanguage: MultiTapLanguageMode = MultiTapLanguageMode.english
    
    var defaultSearchBarButtonClickClosure: (() -> ())? = nil
    var defaultSearchBarTextDidChangeClosure: ((_ searchText: String) -> ())? = nil
    
    public func setCurrentMultitapLanguage(multitapLanguageDictionary: [String:String]) {
        currentMultitapLanguageDictionary = multitapLanguageDictionary
    }
    
    init(withMultitapLanguageDictionary multitapLanguageDictionary: [String:String]) {
        super.init()
        self.setCurrentMultitapLanguage(multitapLanguageDictionary: NumpadDelegateObject.multitapLanguageEnglish)
    }
    
    public func updateMultitapLanguage() {
        switch self.multitapLanguage {
        case .english:
            self.setCurrentMultitapLanguage(multitapLanguageDictionary: NumpadDelegateObject.multitapLanguageEnglish)
        case .bulgarian:
            self.setCurrentMultitapLanguage(multitapLanguageDictionary: NumpadDelegateObject.multitapLanguageBulgarian)
        }
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

                    if let currentMultiTapLanguage = currentMultitapLanguageDictionary, let translatedAccumulatedText = currentMultiTapLanguage[keyPressObject.toString()] {
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

                                    if let currentMultiTapLanguage = self.currentMultitapLanguageDictionary, let translatedAccumulatedText = currentMultiTapLanguage[keyPressObject.toString()] {
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
