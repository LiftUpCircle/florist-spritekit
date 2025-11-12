//
//  StoryData.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import Foundation

struct StoryData: Codable {
    let id: String?
    let title: String
    let scenes: [StoryScene]
    
    /// Returns a unique identifier for this story, using title as fallback
    var storyId: String {
        return id ?? title.lowercased().replacingOccurrences(of: " ", with: "-")
    }
}
