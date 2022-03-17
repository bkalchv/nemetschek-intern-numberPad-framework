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
        
    public override func awakeFromNib() {
        customDelegate = NumpadDelegateObject(withMultitapLanguageDictionary: NumpadDelegateObject.multitapLanguageEnglish)
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
    
    public func toggleInputMode() {
        self.customDelegate.toggleMode()
        self.updateKeyboardType()
    }
    
    public func toggleMultitapLanguage() {
        self.customDelegate.toggleMultitapLanguage()
        self.customDelegate.updateMultitapLanguage()
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
