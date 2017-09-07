import Foundation
import ObjectMapper

class ClassItem: Mappable {

    var quantity: Int = 0
    var discount: Double = 0.0
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        quantity   <- map ["cantidad"]
        discount  <- map["descuento"]
    }
    
}
