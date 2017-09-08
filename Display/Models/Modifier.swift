
import Foundation

class Modifier {
    var id: Int = 0
    var quantity: Int = 0
    var price: Double = 0.0
    var name: String = ""
    
    init(id: Int, quant: Int, price: Double, name: String){
        self.id = id
        self.quantity = quant
        self.price = price
        self.name = name
    }
    
}
