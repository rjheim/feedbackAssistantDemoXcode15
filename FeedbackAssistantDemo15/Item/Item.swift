//
//  Item.swift
//  FeedbackAssistantDemo15
//
//  Created by RJ Heim on 6/6/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var name: String
    var sectionIndex: String

    init(timestamp: Date, name: String, sectionIndex: String) {
        self.timestamp = timestamp
        self.name = name
        self.sectionIndex = sectionIndex
    }
}
