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
    
    private static var T9TrieEN: T9Trie!
    private static var T9TrieBG: T9Trie!
    
    private var currentT9TrieInUse: T9Trie!
    
    public override func awakeFromNib() {
        customDelegate = NumpadDelegateObject(withMultitapLanguageDictionary: NumpadDelegateObject.multitapLanguageEnglish)
        self.delegate = customDelegate
        
        if CustomSearchBar.T9TrieEN == nil {
            CustomSearchBar.T9TrieEN = decodeTrie(trieFilename: "T9Trie_EN")
        
            if let weightedWordsEN = UserDefaults.standard.object(forKey: "weighted_words_EN") as? [String : UInt] {
                weightedWordsEN.forEach { (word, weight) in
                    CustomSearchBar.T9TrieEN.insertWord(word: word, withFrequenceOfUsage: weight)
                }
            }
        }
        
        if CustomSearchBar.T9TrieBG == nil {
            CustomSearchBar.T9TrieBG = decodeTrie(trieFilename: "T9Trie_BG")
//            TODO: insert Bulgarian Weighted Words
                if let weightedWordsBG = UserDefaults.standard.object(forKey: "weighted_words_BG") as? [String : UInt] {
                    weightedWordsBG.forEach { (word, weight) in
                        CustomSearchBar.T9TrieBG.insertWord(word: word, withFrequenceOfUsage: weight)
                    }
                }
        }
        
        self.currentT9TrieInUse = CustomSearchBar.T9TrieEN
        
        //print("CustomSearchBar initialized")
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
        }
    }
    
    public static func updateWeight(forWord word: String) {
        if isWordPresentInWeightedWordsEN(forWord: word) {
            increaseWeightOfWordInWeightedWordsEN(forWord: word)
        } else {
            addNewWordInWeightedWordsEN(word: word)
        }
        
        if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_EN") as? [String : UInt], let frequenceOfUsage = weightedWords[word] {
            CustomSearchBar.T9TrieEN.insertWord(word: word, withFrequenceOfUsage: frequenceOfUsage)
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
                
        case .BG:
            if T9TrieBG == nil {
                T9TrieBG = T9Trie()
            }
            
            for word in words {
                T9TrieBG.insertWord(word: word)
            }
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
    
    public func updateCurrentT9TrieInUse() {
        switch self.customDelegate.t9TrieLanguage {
        case .EN:
            currentT9TrieInUse = CustomSearchBar.T9TrieEN
        case .BG:
            currentT9TrieInUse = CustomSearchBar.T9TrieBG
        }
    }
    
    public func toggleT9TrieLanguage() {
        self.customDelegate.toggleT9TrieLanguage()
        self.updateCurrentT9TrieInUse()
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
        //print(fileUrl.absoluteString)

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
}
