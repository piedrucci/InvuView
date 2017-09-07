
import Foundation

class Payment {
    
    var id: Int = 0
    var name: String = ""
    var amount: Double = 0.0
    
    init(id: Int, name: String, amount: Double){
        self.id = id
        self.name = name
        self.amount = amount
    }
    
}
