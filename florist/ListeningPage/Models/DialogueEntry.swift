//
//  DialogueEntry.swift
//  florist
//
//  Created by Hafi on 04/11/25.
//

import Foundation

struct DialogueEntry: Identifiable {
    let id: UUID
    let characterName: String
    let dialogue: String
    let timestamp: Date
}
