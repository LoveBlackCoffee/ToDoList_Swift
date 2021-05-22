//
//  ToDoListViewController.swift
//  ToDoApp
//
//  Created by kengo kato on 2021/05/15.
//

import UIKit
import Firebase

/// ToDoリスト
class ToDoListViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    private var todoList: [Todo] = []
    private var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        
    }
    
    func setUserId(uid: String) {
        userId = uid
    }
    
    @IBAction func addTaskAction(_ sender: Any) {
        let addView = AddToDoView(frame: self.view.frame)
        addView.delegate = self
        if let userId = userId {
            let todo = Todo(documentId: nil, userId: userId, title: "", message: nil, date: nil)
            addView.setAddNeedData(todoData: todo)
            self.view.addSubview(addView)
        }
    }
    
    private func config() {
        titleLabel.text = "todoTitle".localize()
        addButton.setTitle("addButton".localize(), for: .normal)
        self.tableView.register(UINib(nibName: "TodoCell", bundle: nil), forCellReuseIdentifier: "TodoCell")
        
        getTodoData()
    }
    
    private func getTodoData() {
        if let userId = userId {
            let db = Firestore.firestore()
            db.collection("todo_data").whereField("user_id", isEqualTo: userId)
                .getDocuments() { [weak self] (querySnapshot, err) in
                    guard let strongSelf = self else {
                        return
                    }
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        strongSelf.todoList = []
                        for document in querySnapshot!.documents {
                            let todo = Todo.convertData(dictionary: document.data(), documentId: document.documentID)
                            strongSelf.todoList.append(todo)
                        }
                        strongSelf.tableView.reloadData()
                    }
            }
        }
    }
    
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        if todoList.count > indexPath.row {
            let todo = todoList[indexPath.row]
            let t = todo.title
            if let date = todo.date {
                let dateString = DateUtils.stringFromDate(date: date, format: "YYYY/MM/dd HH:mm")
                cell.config(date: dateString, title: t)
            } else {
                cell.config(date: "", title: t)
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if todoList.count > indexPath.row {
            let todo = todoList[indexPath.row]
            let addView = AddToDoView(frame: self.view.frame)
            addView.delegate = self
            if let userId = userId {
                let todo = Todo(documentId: todo.documentId, userId: userId, title: todo.title, message: todo.message, date: todo.date)
                addView.setAddNeedData(todoData: todo)
                self.view.addSubview(addView)
            }
            
        }
    }
}

extension ToDoListViewController: AddToDoViewDelegate {
    func updateTodoData() {
        getTodoData()
    }
}
