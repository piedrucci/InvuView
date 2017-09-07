
import Foundation

class Discount {
    var id: Int = 0
    var description: String = ""
    var value: Double = 0.0
    var type: String = ""
    
    init(id: Int, description: String, value: Double, type: String){
        self.id = id
        self.description = description
        self.value = value
        self.type = type
    }
    
}
