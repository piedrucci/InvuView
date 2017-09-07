
import Foundation

class Employee {
    
    var id: Int = 0
    var name: String = ""
    var lastName: String = ""
    
    var fullName: String {
        get {
            return name + " " + lastName
        } set (v) {
            name = v
        }
    }
    
    init(id: Int, name: String, lastName: String) {
        self.id = id
        self.name = name
        self.lastName = lastName
    }
    
}
