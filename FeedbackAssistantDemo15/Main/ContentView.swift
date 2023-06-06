//
//  ContentView.swift
//  FeedbackAssistantDemo15
//
//  Created by RJ Heim on 6/6/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var isAddingItem: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("List of Names")
                        .bold()
                } header: {
                    testHeader()
                } footer: {
                    testFooter()
                }

                Section {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        } label: {
                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                        }
                    }
                    .onDelete(perform: deleteItems)
                } header: {
                    testHeader()
                } footer: {
                    testFooter()
                }

                Section {
                    Text("One more Section")
                        .bold()
                } header: {
                    testHeader()
                } footer: {
                    testFooter()
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.custom(0.0)) // TODO: YAY THANKS FOR THIS!!!
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func testHeader() -> some View {
        Text("Test Header")
            .padding(.top, -8) // TODO: How to reduce header spacing without negative padding?
    }

    @ViewBuilder
    private func testFooter() -> some View {
        Text("Test Footer")
            .padding(.bottom, -8) // TODO: How to reduce footer spacing without negative padding?
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
