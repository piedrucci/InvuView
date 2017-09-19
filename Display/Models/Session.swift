//
//  Session.swift
//  Display
//
//  Created by Roberth on 9/19/17.
//  Copyright © 2017 pinneapple. All rights reserved.
//

import Foundation

class Session {
    var id: Int = 0
    var userName: String = ""
    var password: String = ""
    var apiKey: String = ""
    var urlImages: String = ""
    var shopName: String = ""
    var image: Bool = false
    var active: Bool = false
    var loyalty: Bool = false
    var loyaltyName: String = ""
    var bac: Bool = false
    var franchiseId: Int = 0
    var franchiseName: String = ""
    
    init(id: Int, username: String, apikey: String, shopname: String, franchisename: String,
         password: String! = "", urlimages: String! = ""){
        self.id = id
        self.userName = username
        self.apiKey = apikey
        self.shopName = shopname
        self.franchiseName = franchisename
        
        self.password = password
        self.urlImages = urlimages
    }
}
