//
//  ViewController.swift
//  ToDo-Realm
//
//  Created by Sergey on 1/6/21.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    let realm = try! Realm()
    
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setInitialUI()
        loadCategories()
        setNavigationBar()
    }
    
    private func setInitialUI() {
        title = "Categories"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = view.bounds
    }
    
    private func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done
                                                                                  , target: self, action: #selector(handleAddButton))
    }

    
    //MARK: - Selectors
    
    @objc private func handleAddButton() {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let categoryName = textField.text, !categoryName.isEmpty else { return }
            let newCategory = Category()
            newCategory.name = categoryName
            self.save(object: newCategory)
        }
        alert.addTextField { (field) in
            field.placeholder = "Create new category"
            textField = field
        }
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }

    //MARK: - Data Manipulation Functions
    
    func save(object: Object) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print(error)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

//MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet?"
        return cell
    }
    
}

//MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ItemsViewController()
        if let indexPath = tableView.indexPathForSelectedRow {
            vc.selectedCategory = categories?[indexPath.row]
        }
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}

//MARK: - SwipeTableViewCellDelegate

extension CategoryViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let deletedCategory = self.categories?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(deletedCategory)
                    }
                } catch {
                    print(error)
                }
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(systemName: "xmark.bin.fill")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}
