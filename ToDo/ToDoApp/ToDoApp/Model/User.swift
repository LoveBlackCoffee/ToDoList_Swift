//
//  User.swift
//  ToDoApp
//
//  Created by kengo kato on 2021/05/15.
//

import UIKit

struct User: Codable {
    var userId: String
    var mail: String
    var password: String?
    var loginDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case mail
        case password
        case loginDate = "login_date"
    }
    
    func dictionary() -> [String: Any] {
        return ["user_id": userId,
                "mail": mail,
                "password": password ?? "",
                "login_date": loginDate != nil ? DateUtils.stringFromDate(date: loginDate!, format: "yyyyMMddHHmm") : ""
        ]
    }
    
    static func convertData(dictionary :[String : Any]) -> User {
        let date = dictionary["login_date"] as? String ?? ""
        return User(
            userId: dictionary["user_id"] as? String ?? "",
             mail: dictionary["mail"] as? String ?? "",
            password: dictionary["password"] as? String,
            loginDate: date.count > 0 ? DateUtils.dateFromString(string: date, format: "YYYYMMddHHmm"): Date())
    }
    
}
