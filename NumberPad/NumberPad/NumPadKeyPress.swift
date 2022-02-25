//
//  KeyPress.swift
//  NumberPad
//
//  Created by Bogdan Kalchev on 24.02.22.
//

class NumPadKeyPress {
    var value : String = ""
    var timesPressed : Int = 0
    
    let numberToMaximumPresses = [
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
    
    init(fromValue value : String, fromTimesPressed timesPressed : Int) {
        self.value = value
        self.timesPressed = timesPressed
    }
    
    func toString() -> String {
        
        if !value.isEmpty, timesPressed != 0, let maximumPresses = numberToMaximumPresses[self.value]  {
            
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
