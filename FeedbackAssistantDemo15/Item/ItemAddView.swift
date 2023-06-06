//
//  ItemAddView.swift
//  FeedbackAssistantDemo15
//
//  Created by RJ Heim on 6/6/23.
//

import SwiftUI

struct ItemAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""

    private var isAddDisabled: Bool {
        name.isEmpty || email.isEmpty || !email.isValidEmail()
    }
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        TextField("Name", text: $name)
                            .padding()
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(!name.isEmpty ? Color.accentColor : Color.secondary, lineWidth: 2)
                            }
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding()
                            .overlay {
                                if !email.isEmpty {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(email.isValidEmail() && !email.isEmpty ? Color.accentColor : Color.red, lineWidth: 2)
                                } else {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.secondary, lineWidth: 2)
                                }
                            }
                    }
                } footer: {
                    Text("Name must not be empty and Email must not be a valid email")
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // FIXME: Check for duplication and show alert if try to save duplicate. Not needed for demo.
                        addItem(name: name, email: email)

                        dismiss()
                    } label: {
                        Text("Save Item")
                    }
                    .disabled(isAddDisabled)
                }
            }
        }
    }

    private func addItem(name: String, email: String) {
        let newItem = Item(timestamp: Date(), name: name, email: email, sectionIndex: name.first?.uppercased() ?? "")
        modelContext.insert(newItem)
    }
}

#Preview {
    ItemAddView()
        .modelContainer(for: Item.self, inMemory: true)
}
