//
//  ToBuyCategoryViewController.swift
//  do.buy
//
//  Created by Mingu Kang on June/2020.
//  Copyright 2020 Mingu. All rights reserved.
//

import UIKit
import RealmSwift

class ToBuyCategoryViewController: UIViewController {
    
    var i = 0
    var k = 0
    
    let realm = try! Realm()
    
    var categories: Results<BuyCategory>?

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 80/255, green: 156/255, blue: 99/255, alpha: 1.0)
        
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "Cafe24Dangdanghae", size: 32) ?? UIFont.systemFont(ofSize: 30)]

        tableView.delegate = self
        tableView.dataSource = self
        
        loadCategories()
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        
        tableView.isEditing = !tableView.isEditing
        tableView.visibleCells.forEach { cell in
            guard let cell = cell as? BuyCategoryTableViewCell else { return }
            
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
                        categories![k].name = cell.title.text!
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
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let add = UIAlertAction(title: "Add item", style: .default) { action in
            
            if textField.text?.replacingOccurrences(of: " ", with: "") != "" {
                
                let newCategory = BuyCategory()
                newCategory.name = textField.text!
                newCategory.orderPosition = self.i
                
                self.save(category: newCategory, i: self.i)
            }
            
        }
        alert.addAction(add)
        alert.addAction(cancel)
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Add a new category"
        }
        present(alert, animated: true, completion: nil)
    }
    
    func save(category: BuyCategory, i: Int) {
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
        
        categories = realm.objects(BuyCategory.self).sorted(byKeyPath: "orderPosition", ascending: true)
        
        if let order = categories?.last?.orderPosition {
            self.i = order + 1
        }
        
        self.tableView.reloadData()
    }
    
}

extension ToBuyCategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.k = 0
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! BuyCategoryTableViewCell
        
        if tableView.isEditing {
            cell.title.isEnabled = true
        } else {
            cell.title.isEnabled = false
        }
        
        if let category = categories?[indexPath.row] {
            
            var i = 0
            
            if category.item.count > 0 {
                for num in 0...category.item.count - 1 {
                    if !category.item[num].done {
                        i += 1
                    }
                }
                
                cell.title.text = category.name
                cell.title.textColor = UIColor(named: "customTextColor")
                cell.detailLabel.text = "(\(i)/\(category.item.count))"
                cell.detailLabel?.font = .systemFont(ofSize: 14)
                cell.backgroundColor = .clear
                
                if i == 0 {
                    cell.title.font = .italicSystemFont(ofSize: 18)
                    cell.title.textColor = .purple
                    cell.detailLabel.textColor = .systemPink
                    cell.backgroundColor = UIColor(red: 50/255, green: 200/255, blue: 200/255, alpha: 0.7)
                    
                } else {
                    cell.title.font = .systemFont(ofSize: 19, weight: .medium)
                    cell.title.textColor = UIColor(named: "customTextColor")
                    cell.detailLabel.textColor = .none
                    cell.backgroundColor = .clear
                }
                
            } else {
                
                cell.title.text = category.name
                cell.title.font = .systemFont(ofSize: 19, weight: .medium)
                cell.title.textColor = UIColor(named: "customTextColor")
                cell.detailLabel.text = "(0/\(category.item.count))"
                cell.detailLabel.font = .systemFont(ofSize: 14)
                cell.backgroundColor = .clear
                cell.detailLabel.textColor = .none
            }
        }
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ToBuyViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedCategory = categories?[indexPath.row]
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
                        realm.delete(item.item)
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
