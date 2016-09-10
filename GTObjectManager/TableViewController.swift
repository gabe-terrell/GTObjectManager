//
//  TableViewController.swift
//  GTObjectManager
//
//  Created by Gabe Terrell on 6/14/16.
//  Copyright © 2016 Gabe Terrell. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    // MARK: Table Data
    var allContacts = [Contact]()
    var searchResults = [Contact]()
    var activeData : [Contact] {
        return searchController.active ? searchResults : allContacts
    }
    
    // MARK: Table Features
    var searchController: UISearchController!
    private let identifier = "TableViewControllerCell"

    // MARK: - Table Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Contacts"

        self.navigationItem.leftBarButtonItem = editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(createNewContact))
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: identifier)
        
        self.allContacts = Contact.fetchAllContacts()
    }

    // MARK: - Table Data Source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        let contact = activeData[indexPath.row]
        
        var text = ""
        if let firstName = contact.firstName where !firstName.isEmpty {
            text += firstName + " "
        }
        if let lastName = contact.lastName where !lastName.isEmpty {
            text += lastName
        }
        cell.textLabel?.text = text

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let contact = activeData[indexPath.row]
            GTObjectManager.deleteObject(contact)
            GTObjectManager.saveAllChanges()
            
            allContacts = Contact.fetchAllContacts()
            
            if searchController.active {
                self.updateSearchResultsForSearchController(searchController)
            }
            else {
                tableView.reloadData()
            }
        } 
    }

}

// MARK: - Table Functionality & Search
extension TableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
            where !text.isEmpty else {
            searchResults = []
            return
        }
        
        searchResults = Contact.fetchAllContacts(withSearchTerm: text)
        tableView.reloadData()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        tableView.reloadData()
    }
    
    func createNewContact() {
        let alertController = UIAlertController(title: "Enter Contact Information", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler {
            $0.placeholder = "First Name"
            $0.tag = 0
        }
        alertController.addTextFieldWithConfigurationHandler {
            $0.placeholder = "Last Name"
            $0.tag = 1
        }
        
        alertController.addAction(UIAlertAction(title: "Okay", style: .Default) { _ in
            var firstName: String?, lastName: String?
            
            for textField in alertController.textFields! {
                let text = textField.text?.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
                switch textField.tag {
                case 0:
                    firstName = text
                case 1:
                    lastName = text
                default:
                    break
                }
            }
            
            Contact.createContactWithName(first: firstName, last: lastName)
            
            // Note: This is clearly not the most efficient way to reload the data for allContacts
            // but it is simple enough for this demo and demos the features of GTObjectManager
            self.allContacts = Contact.fetchAllContacts()
            
            self.tableView.reloadData()
            }
        )
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
