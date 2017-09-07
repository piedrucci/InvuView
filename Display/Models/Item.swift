import Foundation

class Item {
    
    var id: Int = 0
    var price: Double = 0.0
    var description: String = ""
    var tax: Double = 0.0
    
    var quantity: Int = 0
    
    init(id: Int, price: Double, description: String, tax: Double, quant: Int) {
        self.id = id
        self.price = price
        self.description = description
        self.tax = tax
        self.quantity = quant
    }
    
}
