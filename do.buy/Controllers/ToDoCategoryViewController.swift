//
//  CategoryViewController.swift
//  do.buy
//
//  Created by Mingu Kang on June/2020.
//  Copyright 2020 Mingu. All rights reserved.
//

import UIKit
import RealmSwift


class ToDoCategoryViewController: UIViewController {
    
    var i = 0
    var k = 0
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer()
        self.view.addGestureRecognizer(longPressGesture)
        longPressGesture.addTarget(self, action: #selector(longPressed))
        
        tableView.addGestureRecognizer(longPressGesture)
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 34/255, green: 75/255, blue: 147/255, alpha: 1.0)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "Cafe24Dangdanghae", size: 34) ?? UIFont.systemFont(ofSize: 30)]
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadCategories()
        
    }
    
    @objc func longPressed(_ gesture: UILongPressGestureRecognizer) {
        
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        
        tableView.isEditing = !tableView.isEditing
        tableView.visibleCells.forEach { cell in
            guard let cell = cell as? DoCategoryTableViewCell else { return }
            
            switch tableView.isEditing {
            case true:
                editButton.title = "Done"
                cell.title.isEnabled = true
                cell.title.borderStyle = .roundedRect
                
            case false:
                editButton.title = "⇅"
                cell.title.isEnabled = false
                cell.title.borderStyle = .none
                
                do {
                    try realm.write {
                        self.categories![k].name = cell.title.text!
                        k += 1
                    }
                    tableView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
    
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let add = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            if textField.text?.replacingOccurrences(of: " ", with: "") != "" {
                
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.orderPosition = self.i
                
                self.save(category: newCategory, i: self.i)
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
    
    func save(category: Category, i: Int) {
        do {
            try realm.write {
                realm.add(category)
                category.orderPosition = i
                self.i += 1
            }
        } catch {
            print(error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self).sorted(byKeyPath: "orderPosition", ascending: true)
        
        if let order = categories?.last?.orderPosition {
            self.i = order + 1
        }
        
        self.tableView.reloadData()
    }
}

extension ToDoCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.k = 0
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! DoCategoryTableViewCell
        
        if tableView.isEditing {
            cell.title.isEnabled = true
            
        } else {
            cell.title.isEnabled = false
        }
        
        if let category = categories?[indexPath.row] {
            
            var j = 0
            
            if category.items.count > 0 {
                for num in 0...category.items.count - 1 {
                    if !category.items[num].done {
                        j += 1
                    }
                }
                
                cell.title.text = category.name
                cell.title.textColor = UIColor(named: "customTextColor")
                cell.detailLabel.text =  "(\(j)/\(category.items.count))"
                cell.detailLabel.font = .systemFont(ofSize: 14)
                cell.backgroundColor = .clear
                
                if j == 0 {
                    cell.title.font = .italicSystemFont(ofSize: 18)
                    cell.title.textColor = .purple
                    cell.detailLabel.textColor = .systemBlue
                    cell.backgroundColor = UIColor(red: 200/255, green: 255/255, blue: 80/255, alpha: 0.7)
                    
                } else {
                    cell.title.textColor = UIColor(named: "customTextColor")
                    cell.title.font = .systemFont(ofSize: 19, weight: .medium)
                    cell.detailLabel.textColor = .none
                    cell.backgroundColor = .clear
                }
                
            } else {
                
                cell.title.text = category.name
                cell.title.font = .systemFont(ofSize: 19, weight: .medium)
                cell.title.textColor = UIColor(named: "customTextColor")
                cell.detailLabel.text =  "(0/\(category.items.count))"
                cell.detailLabel.font = .systemFont(ofSize: 14)
                cell.detailLabel.textColor = .none
                cell.backgroundColor = .clear
            }
        }
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if let item = categories?[indexPath.row] {
                do {
                    try realm.write {
                        realm.delete(item.items)
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
                
                let sourceObject = categories![sourceIndexPath.row]
                let destinationObject = categories![destinationIndexPath.row]
                
                let destinationObjectOrder = destinationObject.orderPosition
                
                if sourceIndexPath.row < destinationIndexPath.row {
                    
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        let category = categories![index]
                        category.orderPosition -= 1
                    }
                } else {
                    
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                        let category = categories![index]
                        category.orderPosition += 1
                    }
                }
                
                sourceObject.orderPosition = destinationObjectOrder
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
