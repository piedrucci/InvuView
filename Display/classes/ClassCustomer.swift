import Foundation
import ObjectMapper

class ClassCustomer: Mappable {
    
    var id: String = ""
    var ruc: String = ""
    var name: String = ""
    var lastname: String = ""
    var dob: String = ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id       <- map["id"]
        ruc      <- map["ruc"]
        name     <- map["nombres"]
        lastname <- map["apellidos"]
        dob      <- map["fecha_nacimiento"]
    }
    
}
