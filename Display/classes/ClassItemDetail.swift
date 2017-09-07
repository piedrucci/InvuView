import Foundation
import ObjectMapper

class ClassItemDetail: Mappable {
    var id: Int = 0
    var price: Double = 0.0
    var name: String = ""
    var tax: Double = 0.0
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id    <- map["id"]
        price <- map["precio"]
        name  <- map["nombre"]
        tax   <- map["tax"]
    }
    
}
