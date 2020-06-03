//
//  ToBuyViewController.swift
//  Todoey
//
//  Created by Kang Mingu on 2020/06/01.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ToBuyViewController: UIViewController {
    
    var buyItems = [BuyItem]()

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: BuyCategory? {
        didSet {
//            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
//        searchBar.delegate = self
        
//        loadItems()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        
        tableView.isEditing = !tableView.isEditing
        
        switch tableView.isEditing {
        case true:
            editButton.title = "Done"
            editButton.image = nil
        case false:
            editButton.image = UIImage(systemName: "arrow.up.arrow.down.circle")
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new thing to buy", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let add = UIAlertAction(title: "Add item", style: .default) { action in
            
            if textField.text != "" {
                let newItem = BuyItem()
                if let text = textField.text {
                    newItem.title = text
                }
                newItem.done = false
//                newItem.parentCategory = self.selectedCategory
//                newItem.orderPosition = Int16(self.buyItems.count)
                
                self.buyItems.append(newItem)
                self.saveItem()
                
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(add)
        alert.addTextField { field in
            field.placeholder = "type here"
            textField = field
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    
//    func loadItems(with request: NSFetchRequest<BuyItem> = BuyItem.fetchRequest(), predicate: NSPredicate? = nil) {
//
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
//        do {
//            buyItems = try context.fetch(request)
//        } catch {
//            print(error.localizedDescription)
//        }
//
//    }

}

extension ToBuyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "toBuyItemCell", for: indexPath)
        
        let item = buyItems[indexPath.row]
        
        item.setValue(indexPath.row, forKey: "orderPosition")
        cell.textLabel?.text = item.value(forKey: "title") as? String
        
//        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        cell.accessoryType = item.done == true ? .checkmark : .none
        cell.textLabel?.font = item.done ? .italicSystemFont(ofSize: 16) : .systemFont(ofSize: 17, weight: .medium)
        cell.textLabel?.textColor = item.done ? .systemGray : .black
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//
//        let movedObject = buyItems[sourceIndexPath.row]
//
//        context.delete(buyItems[sourceIndexPath.row])
//        context.insert(buyItems[destinationIndexPath.row])
//
//        buyItems.remove(at: sourceIndexPath.row)
//        buyItems.insert(movedObject, at: destinationIndexPath.row)
//
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        buyItems[indexPath.row].done = !buyItems[indexPath.row].done
        saveItem()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            context.delete(buyItems[indexPath.row])
//            buyItems.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    

    
}


//extension ToBuyViewController: UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request: NSFetchRequest<BuyItem> = BuyItem.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
//
//        self.tableView.reloadData()
//
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadItems()
//
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//}
