import Foundation
import ObjectMapper

class ClassPayment: Mappable {
    
    var detail: PaymentType? = nil
    var amount: Double = 0.0
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        detail <- map["pago"]
        amount <- map["monto"]
    }
    
}
