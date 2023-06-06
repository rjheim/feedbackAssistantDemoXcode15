//
//  ItemSelectionController.swift
//  FeedbackAssistantDemo15
//
//  Created by RJ Heim on 6/6/23.
//


import UIKit

protocol ItemSelectionControllerDelegate: NSObjectProtocol {
    func itemSelectionController(_ controller: ItemSelectionController, didSelectItem item: Item)
}

class ItemSelectionController: UITableViewController {

    struct Section {
        let indexName: String
        let title: String
        let items: [Item]
    }

    private var sections: [Section] = []

    weak var delegate: ItemSelectionControllerDelegate?
    var currentSelection: Item?
    var tintColor: UIColor? = .white

    init(delegate: ItemSelectionControllerDelegate?, items: [Item]) {
        self.delegate = delegate

        let organized = Dictionary(grouping: items, by: { $0.sortIndexCharacter() })

        let sections: [Section] = organized.map { key, value in
            return Section(indexName: key, title: key, items: value.sorted(by: { first, second in
                return first.name < second.name
            }))
        }

        self.sections = sections.sorted(by: { first, second in
            return first.indexName < second.indexName
        })

        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = self.tintColor
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let countrySelection = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = countrySelection.name

        if countrySelection == self.currentSelection {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sections[indexPath.section].items[indexPath.row]
        self.delegate?.itemSelectionController(self, didSelectItem: selectedItem)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { $0.indexName }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

private extension Item {
    func sortIndexCharacter() -> String {
        guard let firstCharacter = name.first else {
            assertionFailure("Country selection cannot have an empty name")
            return ""
        }

        return String(firstCharacter).uppercased()
    }
}
