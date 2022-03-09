//
//  CustomSearchController.swift
//  NumberPad
//
//  Created by Bogdan Kalchev on 2.03.22.
//

import Foundation
import UIKit

class CustomSearchController: UISearchController {

    // Mark this property as lazy to defer initialization until
    // the searchBar property is called.
    private lazy var customSearchBar = CustomSearchBar()

    // Override this property to return your custom implementation.
    override var searchBar: UISearchBar { customSearchBar }
    
    func toggleSearchBarInputMode() {
        customSearchBar.toggleInputMode()
    }
}
