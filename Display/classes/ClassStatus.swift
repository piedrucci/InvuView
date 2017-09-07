import Foundation
import ObjectMapper

class ClassStatus: Mappable {
    
    var id: Int = 0
    var description: String = ""
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id          <- map ["id"]
        description <- map["descripcion"]
    }
    
}
