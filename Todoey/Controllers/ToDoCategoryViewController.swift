//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Kang Mingu on 2020/05/31.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoCategoryViewController: UIViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadCategories()
        
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let add = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            if textField.text != "" {
                
                let newCategory = Category()
                newCategory.name = textField.text!
                
                self.save(category: newCategory)
            }
        }
        
        alert.addAction(add)
        alert.addAction(cancel)
        alert.addTextField { field in
            textField = field
            textField.placeholder = "type here"
        }
        present(alert, animated: true, completion: nil)
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        self.tableView.reloadData()
    }
}

extension ToDoCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Category added yet"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            context.delete(categories[indexPath.row])
//            categories.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
    
    
}
