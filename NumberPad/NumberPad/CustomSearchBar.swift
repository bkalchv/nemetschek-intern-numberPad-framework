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
        customDelegate = NumpadDelegateObject()
        self.delegate = customDelegate
    }
    
    func updateKeyboardType() {
        switch(self.customDelegate.mode) {
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
}
