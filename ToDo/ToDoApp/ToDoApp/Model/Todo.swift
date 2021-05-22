//
//  Todo.swift
//  ToDoApp
//
//  Created by kengo kato on 2021/05/15.
//

import Foundation

/// TODOモデル
struct Todo: Codable {
    var documentId: String?
    var userId: String
    var title: String
    var message: String?
    var date: Date?
    
    func dictionary() -> [String: Any] {
        return ["user_id": userId,
                "title": title,
                "message": message ?? "",
                "date": date != nil ? DateUtils.stringFromDate(date: date!, format: "yyyyMMddHHmm") : ""
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case documentId
        case userId = "user_id"
        case title
        case message
        case date
    }
    
    static func convertData(dictionary :[String : Any], documentId: String?) -> Todo {
        var todo = Todo(
            documentId: documentId,
            userId: dictionary["user_id"] as? String ?? "",
            title: dictionary["title"] as? String ?? "",
            message: dictionary["message"] as? String,
            date: nil)
        
        if let date = dictionary["date"] as? String, date.count > 0 {
            todo.date = DateUtils.dateFromString(string: date, format: "YYYYMMddHHmm")
        }
        return todo
    }
    
}
