//
//  SearchView.swift
//  FeedbackAssistantDemo15
//
//  Created by RJ Heim on 6/6/23.
//

import SwiftData
import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext

    private let keyboardType: UIKeyboardType = .emailAddress
    @State private var maxTokenCount: Int? = 3
    @State private var searchText: String = ""
    @State private var suggestedTokens: [String] = []
    @State private var tokens: [String] = []

    private var shareURL: URL? {
        guard !tokens.isEmpty else {
            return nil
        }

        guard let url = URL(string: "mailto:\(tokens.joined(separator: ","))") else {
            return nil
        }

        return url
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SearchTextField(
                        keyboardType: keyboardType,
                        maxTokenCount: $maxTokenCount,
                        text: $searchText,
                        suggestedTokens: $suggestedTokens,
                        tokens: $tokens) { item in
                            token(item)
                        }
                        .frame(minHeight: 48)
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.secondary, lineWidth: 2)
                        }
                        .padding(4)
                        .onChange(of: searchText) {
                            // TODO: How to do case insensitive?
                            let predicate = #Predicate<Item> {
                                $0.email.contains(searchText) ||
                                $0.name.contains(searchText)
                            }

                            // TODO: How to add sortBy?
                            let descriptor = FetchDescriptor<Item>(predicate: predicate, sortBy: [ SortDescriptor<Item>(\.name)])

                            let items: [Item]? = try? modelContext.fetch(descriptor)
                            // TODO: There are bugs with suggested tokens, but this works for a demo
                            self.suggestedTokens = items.map { $0.email }.sorted { $0 < $1 }.compactMap { tokens.contains($0) ? nil : $0 }
                        }
                } header: {
                    Text("Search")
                        .padding(.leading, 8)
                } footer: {
                    Text("You can enter a name or email to search.")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                Section {
                    VStack(alignment: .leading) {
                        ForEach(tokens, id: \.self) { email in
                            Text(email)
                        }
                        Divider()
                        if let shareURL {
                            ShareLink(item: shareURL)
                        }
                    }
                } header: {
                    Text("Send mail to:")
                } footer: {
                    Text("Click the share button to use these emails with your favorite mail application.")
                }
            }
        }
    }

    private func token(_ item: String) -> UISearchToken {
        let predicate = #Predicate<Item> {
            $0.email == item ||
            $0.name == item
        }

        let descriptor = FetchDescriptor<Item>(predicate: predicate, sortBy: [ SortDescriptor<Item>(\.name)])

        let items: [Item]? = try? modelContext.fetch(descriptor)

        guard let items, !items.isEmpty, let email = items.first?.email else {
            return UISearchToken(icon: UIImage(systemName: "x.circle.fill"), text: "Invalid")
        }

        return UISearchToken(icon: UIImage(systemName: "person.crop.circle.fill"), text: email)
    }
}

#Preview {
    SearchView()
}
