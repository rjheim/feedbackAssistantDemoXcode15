//
//  ItemSelectionView.swift
//  FeedbackAssistantDemo15
//
//  Created by RJ Heim on 6/6/23.
//

import SwiftUI

struct ItemSelectionView: View {

    let availableItems: [Item]

    @Binding var itemSelection: Item?

    var body: some View {
        ItemSelectionIndexedInternalView(availableItems: availableItems, itemSelection: $itemSelection)
            .ignoresSafeArea()
            .navigationTitle("Select a country")
    }
}

private struct ItemSelectionIndexedInternalView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    let availableItems: [Item]

    @Binding var itemSelection: Item?

    typealias UIViewControllerType = ItemSelectionController

    func makeUIViewController(context: Context) -> ItemSelectionController {
        let controller = ItemSelectionController(
            delegate: context.coordinator,
            items: availableItems
        )

        controller.tintColor = nil

        return controller
    }

    func updateUIViewController(_ uiViewController: ItemSelectionController, context: Context) {
        // no-op
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, ItemSelectionControllerDelegate {
        let parent: ItemSelectionIndexedInternalView
        
        init(parent: ItemSelectionIndexedInternalView) {
            self.parent = parent
        }

        func itemSelectionController(_ controller: ItemSelectionController, didSelectItem item: Item) {
            self.parent.itemSelection = item
            self.parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
