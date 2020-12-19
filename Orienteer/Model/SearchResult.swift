//
//  File.swift
//  Orienteer
//
//  Created by Maximilian Burkhardt on 12/15/20.
//

import Foundation

final class SearchResult: ObservableObject {
    @Published var results: [Location];
    
    init(locations: [Location]) {
        results = locations
    }
}
