
import Foundation

class Invoice {
    
    var id: Int = 0
    var invoiceSerial: String = ""
    var discount: Double = 0.0
    var comment: String = ""
    var success: Bool = false
    
    private var invoiceItems: Array<Item> = []
    var items: Array<Item>  {
        get {
            return invoiceItems
        } set (v) {
            invoiceItems = v
        }
    }
    
    private var invoicePayments: Array<Payment> = []
    var payments: Array<Payment>  {
        get {
            return invoicePayments
        } set (v) {
            invoicePayments = v
        }
    }
    
    private var invoiceEmployee: Employee? = nil
    var employee: Employee {
        get {
            return invoiceEmployee!
        } set (v) {
            invoiceEmployee = v
        }
    }
    
    private var invoiceCustomer: Customer? = nil
    var customer: Customer {
        get {
            return invoiceCustomer!
        } set (v) {
            invoiceCustomer = v
        }
    }

    private var invoiceStatus: Status? = nil
    var status: Status {
        get {
            return invoiceStatus!
        } set (v) {
            invoiceStatus = v
        }
    }
    
    init(id: Int, invoiceSerial: String, success: Bool, discount: Double, comment: String) {
        self.id = id
        self.invoiceSerial = invoiceSerial
        self.success = success
        self.discount = discount
        self.comment = comment
    }
    
}
