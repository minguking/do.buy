//
//  ToBuyViewController.swift
//  do.buy
//
//  Created by Mingu Kang on June/2020.
//  Copyright 2020 Mingu. All rights reserved.
//

import UIKit
import RealmSwift

class ToBuyViewController: UIViewController {
    
    var i = 0
    
    let realm = try! Realm()
    
    var buyItems: Results<BuyItem>?
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedCategory: BuyCategory? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 80/255, green: 156/255, blue: 99/255, alpha: 1.0)
        
        navigationItem.title = selectedCategory?.name
        
        tableView.dataSource = self
        tableView.delegate = self
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
        
        let alert = UIAlertController(title: "Add new thing to buy", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let add = UIAlertAction(title: "Add item", style: .default) { action in
            
            if textField.text?.replacingOccurrences(of: " ", with: "") != "" {
                
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = BuyItem()
                            newItem.title = textField.text!
                            newItem.orderPosition = self.i
                            self.i += 1
                            currentCategory.item.append(newItem)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(cancel)
        alert.addAction(add)
        alert.addTextField { field in
            field.placeholder = "type here"
            textField = field
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        buyItems = selectedCategory?.item.sorted(byKeyPath: "orderPosition", ascending: true)
        
        if let order = buyItems?.last?.orderPosition {
            self.i = order + 1
        }
        
        tableView?.reloadData()
    }
    
}

extension ToBuyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buyItems?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "toBuyItemCell", for: indexPath)
        
        if let item = buyItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            cell.accessoryType = item.done == true ? .checkmark : .none
            cell.textLabel?.font = item.done ? .italicSystemFont(ofSize: 16) : .systemFont(ofSize: 17, weight: .medium)
            cell.textLabel?.textColor = item.done ? .systemGray : UIColor(named: "customTextColor")
            
        } else {
            cell.textLabel?.text = "No item added"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        do {
            try realm.write {
                let sourceObject = buyItems![sourceIndexPath.row]
                let destinationObject = buyItems![destinationIndexPath.row]
                
                let destinationObjectOrder = destinationObject.orderPosition
                
                if sourceIndexPath.row < destinationIndexPath.row {
                    
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        let buyItem = buyItems![index]
                        buyItem.orderPosition -= 1
                    }
                } else {
                    
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                        let buyItem = buyItems![index]
                        buyItem.orderPosition += 1
                    }
                }
                
                sourceObject.orderPosition = destinationObjectOrder
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = buyItems?[indexPath.row] {
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
            
            if let item = buyItems?[indexPath.row] {
                
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
    
    
    
}


extension ToBuyViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text?.count == 0 {
            loadItems()
        } else {
            
            buyItems = buyItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title")
        }
        self.tableView.reloadData()
        
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
