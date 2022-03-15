//
//  CustomSearchBar.swift
//  NumberPad
//
//  Created by Bogdan Kalchev on 2.03.22.
//

import Foundation
import UIKit

public class CustomSearchBar : UISearchBar {
    private var customDelegate: NumpadDelegateObject!
    
    private let multiTapLanguageEnglish = [
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
    
    private let multiTapLanguageBulgarian = [
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
    
    public override func awakeFromNib() {
        customDelegate = NumpadDelegateObject()
        customDelegate.setCurrentMultitapLanguage(multitapLanguageDictionary: multiTapLanguageEnglish)
        self.delegate = customDelegate
        print("CustomSearchBar initialized")
    }
    
    public func updateKeyboardType() {
        switch self.customDelegate.mode {
        case .normal:
            self.keyboardType = .default
        case .multiTap:
            self.keyboardType = .asciiCapableNumberPad
        }
    }
    
    public func updateMultiTapLanguage() {
       
        switch self.customDelegate.multitapLanguage {
        case .english:
            self.customDelegate.setCurrentMultitapLanguage(multitapLanguageDictionary: multiTapLanguageEnglish)
        case .bulgarian:
            self.customDelegate.setCurrentMultitapLanguage(multitapLanguageDictionary:  multiTapLanguageBulgarian)
        }
        
    }
    
    public func toggleInputMode() {
        self.customDelegate.toggleMode()
        self.updateKeyboardType()
    }
    
    public func toggleMultitapLanguage() {
        self.customDelegate.toggleMultitapLanguage()
        updateMultiTapLanguage()
    }
    
    public func setDefaultSearchButtonClickedClosure(closure: @escaping () -> Void) {
        if self.customDelegate.defaultSearchBarButtonClickClosure == nil {
            self.customDelegate.defaultSearchBarButtonClickClosure = closure
        }
    }
    
    public func setDefaultSearchBarTextDidChangeClosure(closure: @escaping (_ searchText: String) -> ()) {
        if self.customDelegate.defaultSearchBarTextDidChangeClosure == nil {
            self.customDelegate.defaultSearchBarTextDidChangeClosure = closure
        }
        
    }
}
