//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoViewController: UIViewController {
    
    var i = 0
    
    let realm = try! Realm()

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var toDoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        navigationItem.title = selectedCategory?.name
        
        navigationItem.backBarButtonItem?.tintColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        
        tableView.isEditing = !tableView.isEditing
        
        switch tableView.isEditing {
        case true:
            editButton.title = "Done"
        case false:
            editButton.title = "⇅"
        }
    }
    
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new thing to do", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let add = UIAlertAction(title: "Add item", style: .default) { action in
            
            if textField.text?.replacingOccurrences(of: " ", with: "") != "" {
                
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.orderPosition = self.i
                            self.i += 1
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(add)
        alert.addAction(cancel)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "type here"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "orderPosition", ascending: true)
        
        if let order = toDoItems?.last?.orderPosition {
            self.i = order + 1
        }
        
        tableView?.reloadData()

    }
    
}

extension ToDoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            cell.textLabel?.font = item.done ? .italicSystemFont(ofSize: 16) : .systemFont(ofSize: 17, weight: .medium)
            cell.textLabel?.textColor = item.done ? .systemGray : .none
            
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            if let item = toDoItems?[indexPath.row] {
                do {
                    try realm.write {
                        realm.delete(item)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        do {
            try realm.write {
                let sourceObject = toDoItems![sourceIndexPath.row]
                let destinationObject = toDoItems![destinationIndexPath.row]
                
                let destinationObjectOrder = destinationObject.orderPosition
                
                if sourceIndexPath.row < destinationIndexPath.row {
                    
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        let toDoItem = toDoItems![index]
                        toDoItem.orderPosition -= 1
                    }
                } else {
                    
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                        let toDoItem = toDoItems![index]
                        toDoItem.orderPosition += 1
                    }
                }
                
                sourceObject.orderPosition = destinationObjectOrder
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension ToDoViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text?.count == 0 {
            loadItems()
        } else {
            toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title")
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                self.tableView.reloadData()
            }
        }
    }

}

