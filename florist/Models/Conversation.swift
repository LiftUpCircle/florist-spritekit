//
//  Conversation.swift
//  florist
//
//  Created by Al Amin Dwiesta on 30/10/25.
//

import Foundation

struct Conversation: Identifiable, Codable {
    let conversationId: Int
    var messages: [String]

    var id: Int { conversationId }

    init(conversationId: Int, messages: [String] = []) {
        self.conversationId = conversationId
        self.messages = messages
    }
}
