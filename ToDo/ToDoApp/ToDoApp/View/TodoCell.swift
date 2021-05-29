//
//  TodoCell.swift
//  ToDoApp
//
//  Created by kengo kato on 2021/05/16.
//

import UIKit

protocol TodoCellDelegate: AnyObject {
    func deleteAction(index: Int)
}

class TodoCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate: TodoCellDelegate?
    
    func config(date: String, title: String, index: Int) {
        dateLabel.text = date
        titleLabel.text = title
        deleteButton.setTitle("delete".localize(), for: .normal)
        self.tag = index
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        delegate?.deleteAction(index: self.tag)
    }
}
