
import Foundation

class Discount {
    var porcentaje: Bool = false
    var description: String = ""
    var value: Double = 0.0
    var type: String = ""
    
    init(porcentaje: Bool, description: String, value: Double, type: String){
        self.porcentaje = porcentaje
        self.description = description
        self.value = value
        self.type = type
    }
    
}
