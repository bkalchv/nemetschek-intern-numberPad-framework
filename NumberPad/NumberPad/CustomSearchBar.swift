//
//  CustomSearchBar.swift
//  NumberPad
//
//  Created by Bogdan Kalchev on 2.03.22.
//

import Foundation
import UIKit

public let T9_TRIE_EN_FILENAME = "T9Trie_EN"
public let T9_TRIE_BG_FILENAME = "T9Trie_BG"

public class CustomSearchBar : UISearchBar {
    private var customDelegate: NumpadDelegateObject!
    
    private static var T9TrieEN: T9Trie!
    private static var T9TrieBG: T9Trie!
    private static var currentT9TrieLanguage: T9TrieLanguage = .EN
    
    public override func awakeFromNib() {
        customDelegate = NumpadDelegateObject(withMultitapLanguageDictionary: NumpadDelegateObject.multitapLanguageEnglish)
        self.delegate = customDelegate
        
        if CustomSearchBar.T9TrieEN == nil {
            CustomSearchBar.T9TrieEN = decodeTrie(trieFilename: T9_TRIE_EN_FILENAME)
        
            if let weightedWordsEN = UserDefaults.standard.object(forKey: "weighted_words_EN") as? [String : UInt] {
                weightedWordsEN.forEach { (word, weight) in
                    CustomSearchBar.T9TrieEN.insertWord(word: word, withFrequenceOfUsage: weight)
                }
            }
        }
        
        if CustomSearchBar.T9TrieBG == nil {
            CustomSearchBar.T9TrieBG = decodeTrie(trieFilename: T9_TRIE_BG_FILENAME)
                if let weightedWordsBG = UserDefaults.standard.object(forKey: "weighted_words_BG") as? [String : UInt] {
                    weightedWordsBG.forEach { (word, weight) in
                        CustomSearchBar.T9TrieBG.insertWord(word: word, withFrequenceOfUsage: weight)
                    }
                }
        }
    
    }
    
    private static func isWordPresentInWeightedWordsBG(forWord word: String) -> Bool {
        if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_BG") as? [String : UInt] {
            return weightedWords.contains(where: {$0.key == word})
        }
        return false
    }
    
    private static func increaseWeightOfWordInWeightedWordsBG(forWord word: String) {
        if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_BG") as? [String : UInt] {
            let currentWeightForWord = weightedWords[word]
            
            var weightedWordsTemp = weightedWords
            
            weightedWordsTemp[word] = currentWeightForWord! + 1
            
            UserDefaults.standard.set(weightedWordsTemp, forKey: "weighted_words_BG")
            UserDefaults.standard.synchronize()
        }
    }
    

    private static func addNewWordInWeightedWordsBG(word: String) {
        if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_BG") as? [String : UInt] {
                        
            var weightedWordsTemp = weightedWords
            
            weightedWordsTemp[word] = 1
            
            UserDefaults.standard.set(weightedWordsTemp, forKey: "weighted_words_BG")
            UserDefaults.standard.synchronize()
        }
    }
    
    private static func isWordPresentInWeightedWordsEN(forWord word: String) -> Bool {
        if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_EN") as? [String : UInt] {
            return weightedWords.contains(where: {$0.key == word})
        }
        return false
    }
    
    private static func increaseWeightOfWordInWeightedWordsEN(forWord word: String) {
        if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_EN") as? [String : UInt] {
            let currentWeightForWord = weightedWords[word]
            
            var weightedWordsTemp = weightedWords
            
            weightedWordsTemp[word] = currentWeightForWord! + 1
            
            UserDefaults.standard.set(weightedWordsTemp, forKey: "weighted_words_EN")
            UserDefaults.standard.synchronize()
        }
    }
    
    private static func addNewWordInWeightedWordsEN(word: String) {
        if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_EN") as? [String : UInt] {
                        
            var weightedWordsTemp = weightedWords
            
            weightedWordsTemp[word] = 1
            
            UserDefaults.standard.set(weightedWordsTemp, forKey: "weighted_words_EN")
            UserDefaults.standard.synchronize()
        }
    }
    
    public static func getCurrentT9TrieLanguage() -> T9TrieLanguage {
        return CustomSearchBar.currentT9TrieLanguage
    }
    
    public static func updateWeight(forWord word: String) {
        
        switch CustomSearchBar.currentT9TrieLanguage {
        case .EN:
            if isWordPresentInWeightedWordsEN(forWord: word) {
                increaseWeightOfWordInWeightedWordsEN(forWord: word)
            } else {
                addNewWordInWeightedWordsEN(word: word)
            }
            
            if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_EN") as? [String : UInt], let frequenceOfUsage = weightedWords[word] {
                CustomSearchBar.T9TrieEN.insertWord(word: word, withFrequenceOfUsage: frequenceOfUsage)
            }
        case .BG:
            if isWordPresentInWeightedWordsBG(forWord: word) {
                increaseWeightOfWordInWeightedWordsBG(forWord: word)
            } else {
                addNewWordInWeightedWordsBG(word: word)
            }
            
            if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_BG") as? [String : UInt], let frequenceOfUsage = weightedWords[word] {
                CustomSearchBar.T9TrieBG.insertWord(word: word, withFrequenceOfUsage: frequenceOfUsage)
            }
        }
    }
    
    public static func preloadWords(forLanguage language: T9TrieLanguage, withWords words: [String]) {
        switch language {
        case .EN:
            if T9TrieEN == nil {
                T9TrieEN = T9Trie()
            }
            
            for word in words {
                T9TrieEN.insertWord(word: word)
            }
            
            T9TrieEN.encodeAndCacheTrie(t9TrieFilename: T9_TRIE_EN_FILENAME)
                
        case .BG:
            if T9TrieBG == nil {
                T9TrieBG = T9Trie()
            }
            
            for word in words {
                T9TrieBG.insertWord(word: word)
            }
            
            T9TrieBG.encodeAndCacheTrie(t9TrieFilename: T9_TRIE_BG_FILENAME)
        }
    }
    
    public static func T9SuggestionsDataSource(forT9String t9String: String) -> [String] {
        switch CustomSearchBar.currentT9TrieLanguage {
        case .EN:
            return CustomSearchBar.T9SuggestionsDataSourceEN(forT9String: t9String)
        case .BG:
            return CustomSearchBar.T9SuggestionsDataSourceBG(forT9String: t9String)
        }
    }
    
    public static func T9SuggestionsDataSourceEN(forT9String t9String: String) -> [String] {
        return CustomSearchBar.T9TrieEN.wordSuggestionsAsStrings(forT9String: t9String)
    }
    
    public static func T9SuggestionsDataSourceBG(forT9String t9String: String) -> [String] {
        return CustomSearchBar.T9TrieBG.wordSuggestionsAsStrings(forT9String: t9String)
    }
    
    private func updateKeyboardType() {
        switch self.customDelegate.mode {
        case .normal:
            self.keyboardType = .default
        case .multiTap:
            self.keyboardType = .asciiCapableNumberPad
        case .t9PredictiveTexting:
            self.keyboardType = .asciiCapableNumberPad
        }
    }
    
    public func changeInputMode(toInputMode inputMode: NumpadDelegateObject.SearchBarInputMode) {
        self.customDelegate.setInputMode(toInputMode: inputMode)
        self.updateKeyboardType()
    }
    
    public func toggleMultitapLanguage() {
        self.customDelegate.toggleMultitapLanguage()
        self.customDelegate.updateMultitapLanguage()
    }

    public static func toggleCurrentT9TrieLanguage() {
        switch CustomSearchBar.currentT9TrieLanguage {
        case .EN:
            CustomSearchBar.currentT9TrieLanguage = .BG
        case .BG:
            CustomSearchBar.currentT9TrieLanguage = .EN
        }
    }
    
    public static func changeCurrentT9TrieLanguage(to t9TrieLanguage: T9TrieLanguage) {
        CustomSearchBar.currentT9TrieLanguage = t9TrieLanguage
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
        
    public func executeDefaultSearchButtonClickedClosure() {
        self.customDelegate.searchBarSearchButtonClicked(self)
    }
    
    private func decodeTrie(trieFilename: String) -> T9Trie? {
        
        var result: T9Trie? = nil

        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]

        let fileUrl = cachesDirectoryUrl.appendingPathComponent(trieFilename)

        let filePath = fileUrl.path

        if fileManager.fileExists(atPath: filePath) {
            do {
                let data = try Data(contentsOf: fileUrl)
                let decoder = JSONDecoder()
                result = try decoder.decode(T9Trie.self, from: data)
                print("Trie at \(filePath) decoded.")
            } catch {
                print(error)
            }
        } else {
            print("File \(filePath) doesn't exist")
        }

        return result
    }
    
    public static func determineKeyPressed(forCharacter char: Character) -> Character? {
        if char == " " { return "0" }
        if char == "-" { return "1" }
        
        if char == "A" || char == "B" || char == "C" { return "2" }
        if char == "D" || char == "E" || char == "F" { return "3" }
        if char == "G" || char == "H" || char == "I" { return "4" }
        if char == "J" || char == "K" || char == "L" { return "5" }
        if char == "M" || char == "N" || char == "O" { return "6" }
        if char == "P" || char == "Q" || char == "R" || char == "S" { return "7" }
        if char == "T" || char == "U" || char == "V" { return "8" }
        if char == "W" || char == "X" || char == "Y" || char == "Z" { return "9" }
        
        if char == "А" || char == "Б" || char == "В" || char == "Г" { return "2" }
        if char == "Д" || char == "Е" || char == "Ж" || char == "З" { return "3" }
        if char == "И" || char == "Й" || char == "К" || char == "Л" { return "4" }
        if char == "М" || char == "Н" || char == "О" || char == "П" { return "5" }
        if char == "Р" || char == "С" || char == "Т" || char == "У" { return "6" }
        if char == "Ф" || char == "Х" || char == "Ц" || char == "Ч" { return "7" }
        if char == "Ш" || char == "Щ" || char == "Ъ" || char == "ь" { return "8" }
        if char == "Ь" || char == "Э" || char == "Ю" || char == "Я" { return "9" }
        
        return nil
    }
    
    public static func t9Stringify(text: String) -> String {
        
        var t9String: String = ""
        
        let letters = CharacterSet.letters
        let digits = CharacterSet.decimalDigits
        let whitespaces = CharacterSet.whitespaces
        
        for charUnicode in text.unicodeScalars {
            if letters.contains(charUnicode), let keyBeingPressedForLetter = CustomSearchBar.determineKeyPressed(forCharacter: Character(charUnicode)) {
                t9String.append(keyBeingPressedForLetter)
            } else if digits.contains(charUnicode) {
                t9String.append(String(charUnicode))
            } else if whitespaces.contains(charUnicode) {
                t9String.append("0")
            } else if String(charUnicode) == "-" {
                t9String.append("1")
            }
        }
        
        return t9String
    }
    
}
