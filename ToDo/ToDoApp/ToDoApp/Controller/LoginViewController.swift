//
//  ViewController.swift
//  ToDoApp
//
//  Created by kengo kato on 2021/05/15.
//

import UIKit
import Firebase

/// ログイン画面
class LoginViewController: UIViewController {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var idTextField: DoneTextField!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var passTextField: DoneTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeNotification()
    }

    private func config() {
        idLabel.text = "idText".localize()
        passLabel.text = "passText".localize()
        loginButton.setTitle("loginButton".localize(), for: .normal)
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
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height * 1.2)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    /// ログイン処理
    /// - Parameters:
    ///   - mail: メール
    ///   - password: パスワード
    ///   - complete:　成功、失敗　uid
    private func login(mail: String, password: String, complete:(@escaping (Bool, String?) -> ())) {
        Auth.auth().signIn(withEmail: mail, password: password) {[weak self] authResult, error in
            guard let strongSelf = self else {
                complete (false, nil)
                return
            }
            if error != nil {
                complete (false, nil)
            } else {
                let uid = authResult?.user.uid
                strongSelf.updateUserInfo(uid: uid)
                complete(true, uid)
            }
        }
    }
    
    /// ユーザ情報の更新
    /// - Parameter uid
    private func updateUserInfo(uid: String?) {
        guard let uid = uid else {
            return
        }
        let db = Firestore.firestore()
        let docRef = db.collection("user").document(uid)
        docRef.getDocument { [weak self] (document, error) in
            guard let strongSelf = self else {
                return
            }
            if let document = document, document.exists, let userData = document.data() {
                var user = User.convertData(dictionary: userData)
                // 現状特に使用をしていないが、ログイン日時を更新するようにしている
                user.loginDate = Date()
                strongSelf.updateUserInfoData(userData: user)
            } else {
                
            }
        }
    }
    
    /// データ更新
    /// - Parameter userData: ユーザ情報
    private func updateUserInfoData(userData: User) {
        let db = Firestore.firestore()
        db.collection("user").document(userData.userId).setData(userData.dictionary(), merge: true, completion: { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {

            }
        })
    }
    
    
    private func transitionTodoList(uid: String) {
        let storyboard: UIStoryboard = UIStoryboard(name: "ToDo", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "ToDoList") as! ToDoListViewController
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.setUserId(uid: uid)
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        guard let id = self.idTextField.text, let pass = self.passTextField.text else {
            return
        }
        if id.count > 0, pass.count > 0 {
            self.login(mail: id, password: pass) {  [weak self] success, uid in
                guard let strongSelf = self else {
                    return
                }
                
                if success {
                    if let uid = uid {
                        strongSelf.transitionTodoList(uid: uid)
                    }
                } else {
                    Util.showAlert(title: "error".localize(), message: "loginError".localize(), positiveButton: "ok".localize())
                }
            }
        } else {
            Util.showAlert(title: "error".localize(), message: "NotEntered".localize(), positiveButton: "ok".localize())
        }
    }
    
}
