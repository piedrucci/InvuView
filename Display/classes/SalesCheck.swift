import Foundation
import ObjectMapper

class SalesCheck: Mappable {
    
    var id      : String = ""
    var discount: String = ""
    var checkNum: String = ""
    var comment : String = ""
    var items   : [Item] = []
    var payments: [Payment] = []
    var employee: Employee! = nil
    var customer: Customer! = nil
    var success : Bool = false
    var status  : Status! = nil
    var message : String = ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id       <- map["id"]
        checkNum <- map["num_cita"]
        comment  <- map["comentario"]
        discount <- map["descuento"]
        items    <- map["items"]
        payments <- map["pagos"]
        employee <- map["empleado"]
        customer <- map["cliente"]
        success  <- map["encontro"]
        status   <- map["status"]
        message  <- map["msg"]
    }
    
}
