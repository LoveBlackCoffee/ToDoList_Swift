//
//  AddToDoView.swift
//  ToDoApp
//
//  Created by kengo kato on 2021/05/16.
//

import UIKit
import Firebase

///追加画面

protocol AddToDoViewDelegate: AnyObject {
    func updateTodoData()
}

class AddToDoView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: DoneTextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTextField: DoneTextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dateSwtich: UISwitch!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var todoData: Todo!
    private var userId: String?
    private var document: String?
    weak var delegate: AddToDoViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        config()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
        config()
    }
    
    private func setNotification() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeNotification() {
        let notification = NotificationCenter.default
        notification.removeObserver(self,name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notification.removeObserver(self,name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        scrollView.contentSize = CGSize(width: self.frame.size.width, height: self.frame.size.height * 1.2)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        removeNotification()
        self.removeFromSuperview()
    }
    
    func setAddNeedData(todoData: Todo) {
        self.todoData = todoData
        self.userId = todoData.userId
        self.document = todoData.documentId
        
        titleTextField.text = todoData.title
        messageTextField.text = todoData.message
        
        if let date = todoData.date {
            dateSwtich.isOn = true
            datePicker.isHidden = false
            datePicker.setDate(date, animated: false)
        } else {
            dateSwtich.isOn = false
            datePicker.isHidden = true
        }
    }
    
    private func config() {
        titleLabel.text = "title".localize()
        messageLabel.text = "message".localize()
        dateLabel.text = "date".localize()
        cancelButton.setTitle("cancel".localize(), for: .normal)
        addButton.setTitle("add".localize(), for: .normal)
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapped(_:)))
        self.addGestureRecognizer(tapGesture)
        
        setNotification()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "AddToDoView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = self.bounds
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.5)
        self.addSubview(view)
    }
    
    private func updateData(sendData: [String: Any], complete: @escaping ((Bool) -> ())) {
        if let document = document {
            let db = Firestore.firestore()
            db.collection("todo_data").document(document).setData(sendData, merge: true, completion: { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    complete(false)
                } else {
                    complete(true)
                }
            })
        } else {
            complete(false)
        }
    }
    
    private func addData(sendData: [String: Any], complete: @escaping ((Bool) -> ())) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        
        ref = db.collection("todo_data").addDocument(data: sendData) { err in
            if let err = err {
                print("Error adding document: \(err)")
                complete(false)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                complete(true)
            }
        }
    }
    
    private func addTodo(isEdit: Bool) {
        if let title = titleTextField.text, title.count > 0 {
            let message = messageTextField.text
            let date = dateSwtich.isOn ? datePicker.date : nil
            let sendData = Todo(userId: self.userId!, title: title, message: message, date: date).dictionary()
            
            if isEdit {
                updateData(sendData: sendData) {[weak self] success in
                    guard let strongSelf = self else {
                        return
                    }
                    if success {
                        strongSelf.delegate?.updateTodoData()
                        strongSelf.removeFromSuperview()
                    }
                }
            } else {
                addData(sendData: sendData) {[weak self] success in
                    guard let strongSelf = self else {
                        return
                    }
                    if success {
                        strongSelf.delegate?.updateTodoData()
                        strongSelf.removeFromSuperview()
                    }
                }
            }
        } else {
            Util.showAlert(title: "error".localize(), message: "titleIsNone", positiveButton: "ok".localize())
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        removeNotification()
        self.removeFromSuperview()
    }
    
    @IBAction func dateSwitchAction(_ sender: Any) {
        let s = sender as! UISwitch
        datePicker.isHidden = !s.isOn
    }
    
    @IBAction func addAction(_ sender: Any) {
        if let _ = document {
            Util.showAlert(title: "confirm".localize(),
                                message: "editTask".localize(),
                                positiveButton: "edit".localize(),
                                negativeButton: "cancel".localize(),positiveAction: {
                                    self.addTodo(isEdit: true)
                                },
                                negativeAction:  {})
        } else {
            Util.showAlert(title: "confirm".localize(),
                                message: "addTask".localize(),
                                positiveButton: "add".localize(),
                                negativeButton: "cancel".localize(),
                                positiveAction: {
                                    self.addTodo(isEdit: false)
                                },
                                negativeAction:  {})
        }
    }
}
