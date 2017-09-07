

import Foundation

class Customer {
    
    var id: Int = 0
    var ruc: String = ""
    var name: String = ""
    var lastName: String = ""
    var dob: String = ""
    
    var fullName: String {
        get {
            return name + " " + lastName
        } set (v) {
            name = v
        }
    }
    
    init(id: Int, ruc: String, name: String, lastName: String, dob: String) {
        self.id = id
        self.ruc = ruc
        self.name = name
        self.lastName = lastName
        self.dob = dob
    }
    
    
    
}
