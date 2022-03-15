//
//  KeyPress.swift
//  NumberPad
//
//  Created by Bogdan Kalchev on 24.02.22.
//

class NumPadKeyPress {
    var value : String = ""
    var timesPressed : Int = 0
    var languageMode : MultiTapLanguageMode = MultiTapLanguageMode.english
    
    let numberToMaximumPressesEnglish = [
        "1" : 3,
        "2" : 3,
        "3" : 3,
        "4" : 3,
        "5" : 3,
        "6" : 3,
        "7" : 4,
        "8" : 3,
        "9" : 4
    ]
    
    let numberToMaximumPressesBulgarian = [
        "1" : 4,
        "2" : 4,
        "3" : 4,
        "4" : 4,
        "5" : 4,
        "6" : 4,
        "7" : 4,
        "8" : 4,
        "9" : 4
    ]
    
    init(fromValue value: String, fromTimesPressed timesPressed: Int, forMultitapLanguageMode multitapLanguageMode: MultiTapLanguageMode) {
        self.value = value
        self.timesPressed = timesPressed
        self.languageMode = multitapLanguageMode
    }
    
    func maximumPressesForCurrentLanguage() -> Int? {
        switch languageMode {
            case .english:
                let maximumPresses = numberToMaximumPressesEnglish[self.value]
                return maximumPresses
            case .bulgarian:
                let maximumPresses = numberToMaximumPressesBulgarian[self.value]
                return maximumPresses
        }
    }
    
    func toString() -> String {
        
        if !value.isEmpty, timesPressed != 0, let maximumPresses = maximumPressesForCurrentLanguage() {
            
            let remainder = timesPressed % maximumPresses
            
            if remainder == 0 {
                return String.init(repeating: value, count: maximumPresses)
            } else {
                return String.init(repeating: value, count: remainder)
            }
            
        }
        
        return ""
    }
}
