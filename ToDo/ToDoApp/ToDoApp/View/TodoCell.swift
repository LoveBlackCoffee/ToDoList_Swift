//
//  TodoCell.swift
//  ToDoApp
//
//  Created by kengo kato on 2021/05/16.
//

import UIKit


class TodoCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    func config(date: String, title: String) {
        dateLabel.text = date
        titleLabel.text = title
    }
    
}
