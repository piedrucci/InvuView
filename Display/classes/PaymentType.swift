import Foundation
import ObjectMapper

class PaymentType: Mappable {
    var id: UInt64 = 0
    var type: Int = 0
    var name: String = ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id   <- map["id"]
        type <- map["tipo"]
        name <- map["nombre"]
    }
    
}
