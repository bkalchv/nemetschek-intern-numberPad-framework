//
//  T9Trie.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 21.03.22.
//

import Foundation

internal class T9Trie : Codable {
    
    static let T9TRIE_ROOT_VALUE: String = ""
    
    private let root: T9TrieNode
    
    public init() {
        root = T9TrieNode(value: T9Trie.T9TRIE_ROOT_VALUE)!
    }

    func t9String(fromString string: String) -> String? {
        
        var t9String: String = ""
        
        for currentCharacter in string.uppercased() {
            if let keyPressed = CustomSearchBar.determineKeyPressed(forCharacter: currentCharacter) {
                t9String.append(keyPressed)
            } else {
                return nil
            }
        }
        
        return t9String
    }
        
    public func insertWord(word: String) {
        
        guard !word.isEmpty else { return }
        
        var currentNode = root
        
        if let wordAsT9String = t9String(fromString: word) {
            for keypressValue in wordAsT9String {
                if let child = currentNode.children[String(keypressValue)] {
                    currentNode = child
                } else {
                    currentNode.addToChildren(childValue: String(keypressValue))
                    currentNode = currentNode.children[String(keypressValue)]!
                }
            }
            currentNode.isEndOfWord = true
            let T9WordSuggestionCandidate = T9TrieWord(withValue: word)
            
            if currentNode.containsT9WordInSuggestions(forT9Word: T9WordSuggestionCandidate) {
                currentNode.increaseFrequenceOfUsageOfT9Word(ofT9Word: T9WordSuggestionCandidate)
            } else {
                currentNode.insertT9WordInSuggestions(forT9Word: T9WordSuggestionCandidate)
            }
        }
    }
    
    public func insertWord(word: String, withFrequenceOfUsage frequenceOfUsage: UInt) {
        guard !word.isEmpty else { return }
        
        var currentNode = root
        
        if let wordAsT9String = t9String(fromString: word) {
            for keypressValue in wordAsT9String {
                if let child = currentNode.children[String(keypressValue)] {
                    currentNode = child
                } else {
                    currentNode.addToChildren(childValue: String(keypressValue))
                    currentNode = currentNode.children[String(keypressValue)]!
                }
            }
            currentNode.isEndOfWord = true
            let T9WordSuggestionCandidate = T9TrieWord(withValue: word, withFrequenceOfUsage: frequenceOfUsage)
            
            if currentNode.containsT9WordInSuggestions(forT9Word: T9WordSuggestionCandidate) {
                currentNode.setFrequenceOfUsageOfWord(ofWord: T9WordSuggestionCandidate, frequenceOfUsage: frequenceOfUsage)
            } else {
                currentNode.insertT9WordInSuggestions(forT9Word: T9WordSuggestionCandidate)
            }
        }
    }
    
    func containsWord(word: String) -> Bool {
        
        if word.isEmpty { return true }
        
        var currentNode = root
        
        if let wordAsT9String = t9String(fromString: word) {
            for keypressValue in wordAsT9String {
                if let child = currentNode.children[String(keypressValue)] {
                    currentNode = child
                } else {
                    return false
                }
            }
            
            return currentNode.suggestedT9Words.contains(where: {$0.value == word})
        } else {
            return false
        }
    }
    
    func hasSuchPath(forT9String t9String: String) -> Bool {

        var currentNode = root

        for keypressValue in t9String {
            if let child = currentNode.children[String(keypressValue)] {
                currentNode = child
            } else {
                return false
            }
        }
        
        return true
    }
    
    public func wordSuggestions(forT9String t9String: String) ->[T9TrieWord]? {
        
        var currentNode = root

        for keypressValue in t9String {
            if let child = currentNode.children[String(keypressValue)] {
                currentNode = child
            } else {
                return nil
            }
        }
        
        if !currentNode.isEndOfWord { return nil }
        
        return currentNode.suggestedT9Words
    }
    
    public func wordSuggestionsAsStrings(forT9String t9String: String) -> [String] {
        var wordSuggestionsAsStrings: [String] = [String]()
        if let wordSuggestions = wordSuggestions(forT9String: t9String) {
            wordSuggestionsAsStrings = wordSuggestions.map{ $0.value.uppercased() }
        }
        return wordSuggestionsAsStrings
    }
    
    public func isEmpty() -> Bool {
        return root.children.isEmpty
    }
    
    func doesTrieExist(t9TrieFilename: String) -> Bool {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]
        
        // TODO: decide what extension
        let fileUrl = cachesDirectoryUrl.appendingPathComponent(t9TrieFilename)
                
        let filePath = fileUrl.path
        
        return fileManager.fileExists(atPath: filePath)
    }
    
    func encodeAndCacheTrie(t9TrieFilename: String) {
        if !doesTrieExist(t9TrieFilename: t9TrieFilename) {
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            let cachesDirectoryUrl = urls[0]
            // TODO: decide what extension
            let fileUrl = cachesDirectoryUrl.appendingPathComponent(t9TrieFilename)
            let filePath = fileUrl.path
            
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(self)
                try data.write(to: fileUrl)
                print("File \(filePath) created")
            } catch {
                print(error)
            }
        }
    }
}
