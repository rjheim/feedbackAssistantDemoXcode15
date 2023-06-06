//
//  ItemListView.swift
//  FeedbackAssistantDemo15
//
//  Created by RJ Heim on 6/6/23.
//

import SwiftUI
import SwiftData

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var isAddingItem: Bool = false

    @State private var selectedItem: Item?
    @State private var isSelectingItem: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("You can add contacts by name and email here!")
                } header: {
                    testHeader("Names")
                } footer: {
                    testFooter("Please don't add duplicates :)")
                }

                Section {
                    ForEach(items) { item in
                        NavigationLink {
                            itemView(item: item)
                        } label: {
                            Text(item.name)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Button("Select Item") {
                                isSelectingItem = true
                            }
                            
                            if let selectedItem {
                                Text(selectedItem.name)
                            } else {
                                Text("No item selected")
                            }
                        }
                        Spacer()
                    }
                } header: {
                    testHeader("Select an item")
                } footer: {
                    testFooter("This is a selected item from a table with Selected Index Items.")
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(.custom(0.0)) // TODO: YAY THANKS FOR THIS!!!
            .sheet(isPresented: $isAddingItem) {
                ItemAddView()
            }
            .sheet(isPresented: $isSelectingItem) {
                ItemSelectionView(availableItems: items, itemSelection: $selectedItem)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button {
                        isAddingItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func testHeader(_ text: String) -> some View {
        Text(text)
            .padding(.top, -4) // TODO: How to reduce header spacing without negative padding?
    }

    @ViewBuilder
    private func testFooter(_ text: String) -> some View {
        Text(text)
            .padding(.bottom, -4) // TODO: How to reduce footer spacing without negative padding?
    }

    @ViewBuilder
    private func itemView(item: Item) -> some View {
        VStack(spacing: 12) {
            Text("Name: \(item.name)")
            Text("Email: \(item.email)")
            Text("Item created at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
        }
        .font(.title3)
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
        .background {
            Color(uiColor: .secondarySystemBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
    ItemListView()
        .modelContainer(for: Item.self, inMemory: true)
}
