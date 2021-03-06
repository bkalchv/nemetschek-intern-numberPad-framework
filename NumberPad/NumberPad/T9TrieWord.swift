//
//  T9TrieWord.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 23.03.22.
//

import Foundation

internal class T9TrieWord: Equatable, CustomStringConvertible, Codable {
    
    var value: String
    var frequenceOfUsage: UInt
    
    public init(withValue value: String, withFrequenceOfUsage frequence: UInt = 0) {
        self.value = value
        self.frequenceOfUsage = frequence
    }
    
    private enum CodingKeys: String, CodingKey {
        case value
        case frequenceOfUsage
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(String.self, forKey: CodingKeys.value)
        self.frequenceOfUsage = try container.decode(UInt.self, forKey: CodingKeys.frequenceOfUsage)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.value, forKey: CodingKeys.value)
        try container.encode(self.frequenceOfUsage, forKey: CodingKeys.frequenceOfUsage)
    }
    
    public var description: String {
        return "[\(value)] : \(frequenceOfUsage)"
    }
    
    public static func == (lhs: T9TrieWord, rhs: T9TrieWord) -> Bool {
        return lhs.value == rhs.value
    }
}
