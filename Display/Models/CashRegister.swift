

import Foundation

class CashRegister {
    
    var id: Int = 0
    var ip_raspberry: String = ""
    var name: String = ""
    var ip_precuenta: String = ""
    var precuentaAlCerrar: Bool = false
    var barcode: Bool = false
    var comandaAlCerrar: Bool = false
    
    init(id: Int, name: String, ip_raspberry: String,
         ip_precuenta: String, precuentaAlCerrar: Bool = false,
         barcode: Bool = false, comandaAlCerrar: Bool = false) {
        self.id = id
        self.name = name
        self.ip_raspberry = ip_raspberry
        self.ip_precuenta = ip_precuenta
        self.barcode = barcode
        self.comandaAlCerrar = comandaAlCerrar
    }
    
}
