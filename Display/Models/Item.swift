import Foundation

class Item {
    
    var id: Int = 0
    var price: Double = 0.0
    var description: String = ""
    var tax: Double = 0.0
    
    var quantity: Int = 0
    
    var amountItem: Double = 0.0
    var amountTax: Double = 0.0
    var amountModifiers: Double = 0.0
    
    private var itemModifiers: Array<Modifier> = []
//    private var itemModifiers = Array<Modifier>()
    var modifiers: Array<Modifier> {
        get {
            return itemModifiers
        } set (v) {
            itemModifiers = v
        }
    }
    
    
    init(id: Int, price: Double, description: String, tax: Double, quant: Int, modifiers: Array<Modifier>, amountMod: Double) {
        self.id = id
        self.price = price
        self.description = description
        self.tax = tax
        self.quantity = quant
        
        self.amountItem = price * Double(quant)
        self.amountTax  = (tax * price) / 100
        
        self.itemModifiers = modifiers
        self.amountModifiers = amountMod
    }
    
}
