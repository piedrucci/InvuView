import Foundation
import ObjectMapper

class ClassEmployee: Mappable {
    
    var id: String = ""
    var name: String = ""
    var lastname: String = ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id       <- map["id"]
        name     <- map["nombres"]
        lastname <- map["apellidos"]
    }
    
}
