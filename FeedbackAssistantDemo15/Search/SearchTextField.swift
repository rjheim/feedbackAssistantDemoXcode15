//
//  SearchTextField.swift
//  FeedbackAssistantDemo15
//
//  Created by RJ Heim on 6/6/23.
//

import SwiftUI
import UIKit

struct SearchTextField {
    let keyboardType: UIKeyboardType
    @Binding var maxTokenCount: Int?
    @Binding var text: String
    @Binding var suggestedTokens: [String]
    @Binding var tokens: [String]
    let token: (String) -> UISearchToken
}

extension SearchTextField: UIViewRepresentable {
    class Coordinator: NSObject {
        let parent: SearchTextField

        init(_ parent: SearchTextField) {
            self.parent = parent
        }
    }

    func makeUIView(context: Context) -> UISearchTextField {
        let searchTextField = UISearchTextField()
        searchTextField.delegate = context.coordinator

        // TODO: How to change textfield background color???
        searchTextField.backgroundColor = .white // TODO: This seems to do nothing
        searchTextField.tintColor = .black // TODO: Changes the cursor only??

        searchTextField.leftViewMode = .never
        searchTextField.leftView = nil

        searchTextField.tokenBackgroundColor = .systemGray6
        searchTextField.autocorrectionType = .no
        searchTextField.autocapitalizationType = .none
        searchTextField.keyboardType = self.keyboardType

        updateSearchSuggestions(searchTextField: searchTextField)

        return searchTextField
    }

    func updateUIView(_ searchTextField: UISearchTextField, context: Context) {
        searchTextField.text = text
        searchTextField.tokens = tokens.map { token($0) }
        updateSearchSuggestions(searchTextField: searchTextField)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func updateSearchSuggestions(searchTextField: UISearchTextField) {
        if #available(iOS 16.0, iOSApplicationExtension 16.0, *) {
            let searchSuggestions: [UISearchSuggestionItem] = suggestedTokens.map { UISearchSuggestionItem(localizedSuggestion: $0) }
            searchTextField.searchSuggestions = searchSuggestions
        }
    }
}

extension SearchTextField.Coordinator: UISearchTextFieldDelegate {
    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            DispatchQueue.main.async {
                self.parent.tokens.append(text)
                self.parent.text = ""
            }
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.parent.tokens = []
            self.parent.text = ""
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            DispatchQueue.main.async {
                self.parent.tokens.append(text)
                self.parent.text = ""
            }
        }
        return true
    }

    /// Asks the delegate whether to change the specified text.
    /// - Parameters:
    ///   - textField: The text field containing the text.
    ///   - range: The range of characters to be replaced.
    ///   - string: The replacement string for the specified range.
    ///   During typing, this parameter normally contains only the single new character that was typed, but it may contain more characters if the user is pasting text.
    ///   When the user deletes one or more characters, the replacement string is empty.
    /// - Returns: true if the specified text range should be replaced; otherwise, false to keep the old text.
    /// Tokens have negative location in range. The shouldChangeCharactersIn range is the selected text that is being replaced by the replacementString.
    /// If the replacement string is empty, a key like return or delete was pressed after making the selection
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // If location is less than 0, and the length is greater than 0, the a token is selected and being replaced or deleted
        guard range.location < 0, range.length > 0 else {
            // Prevent user from adding more text or tokens if they have reached the max number of tokens.
            if let maxTokenCount = self.parent.maxTokenCount, self.parent.tokens.count == maxTokenCount {
                return false
            }
            return true
        }
        // Since the location is negative, we want to subtract the absolute number from the token count to get the index.
        // For the length of the selection, we want to add the offset
        // i.e. token count is 3 (with indices 0, 1, 2). Location can then be -3, -2 or -1.
        // If the the range location is -1, that means we need the last token, so count - 1 + 0 offset = 2, which is the last token index
        // If we want to delete the first two tokens, we take count(3) - 3 + 0 = 0 to remove the first token.
        // This updates the count to 2, so on the next iteration it's count(2) - 3 + 1 = 0, which again removes the first token, which is now the second token.
        for offset in 0..<range.length {
            let tokenIndex = self.parent.tokens.count - abs(range.location) + offset
            guard self.parent.tokens[safeIndex: tokenIndex] != nil else {
                return false
            }
            DispatchQueue.main.async {
                self.parent.tokens.remove(at: tokenIndex)
            }
        }
        // Prevents other tokens from being selected or deleted on subsequent calls.
        // This does prevent the user from pasting or typing something over a token, but they can paste or type again after it's deleted.
        return false
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard var text = textField.text, !text.isEmpty else {
            // No text
            DispatchQueue.main.async {
                self.parent.text = ""
            }
            return
        }

        // If last character is logical separator that is not an allowed special character !#$%&'*+-/=?^_`{|}~
        guard text.last == ";" || text.last == "," || text.last == " " || text.last == ":" else {
            // Still typing an email
            // Update search text so parent view can update search suggestions
            DispatchQueue.main.async {
                self.parent.text = text
            }
            return
        }

        // Remove separator and instantiate constant for new token
        text.removeLast()
        let value = text

        // Make sure token isn't empty
        guard !value.isEmpty else {
            DispatchQueue.main.async {
                self.parent.text = ""
            }
            return
        }

        DispatchQueue.main.async {
            // Add token to tokens array
            self.parent.tokens.append(text)
            self.parent.text = ""
        }
    }

    // MARK: - UISearchTextFieldDelegate
    @available(iOSApplicationExtension 16.0, iOS 16.0, *)
    func searchTextField(_ searchTextField: UISearchTextField, didSelect suggestion: UISearchSuggestion) {
        let address: String = {
            if let localizedSuggestion = suggestion.localizedSuggestion {
                return localizedSuggestion
            } else {
                assertionFailure("no localized suggestion")
                return ""
            }
        }()

        DispatchQueue.main.async {
            self.parent.tokens.append(address)
            self.parent.text = ""
        }
    }
}

#if DEBUG

struct SearchTextField_Previews: PreviewProvider {
    @State static var text: String = ""
    @State static var suggestedTokens: [String] =
    [
        "momo.the.gatito@aol.com",
        "wowATestEmail@test.com"
    ]
    @State static var tokens: [String] = []
    static let keyboardType: UIKeyboardType = .emailAddress
    @State static var maxTokenCount: Int? = 3

    static var previews: some View {
        Group {
            List {
                HStack {
                    Text("To:")
                    SearchTextField(
                        keyboardType: keyboardType,
                        maxTokenCount: $maxTokenCount,
                        text: $text,
                        suggestedTokens: $suggestedTokens,
                        tokens: $tokens
                    ) { text in
                        UISearchToken(icon: nil, text: text)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)

            SearchTextField(
                keyboardType: keyboardType,
                maxTokenCount: $maxTokenCount,
                text: .constant("valid@vaid.com"),
                suggestedTokens: .constant(["momo.the.gatito@aol.com"]),
                tokens: .constant([])
            ) { text in
                UISearchToken(icon: nil, text: text)
            }
        }
    }
}

#endif

