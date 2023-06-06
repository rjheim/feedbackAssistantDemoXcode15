//
//  ContentView.swift
//  FeedbackAssistantDemo15
//
//  Created by RJ Heim on 6/6/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            ItemListView()
                .tabItem {
                    Label("Items", systemImage: "pencil")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
