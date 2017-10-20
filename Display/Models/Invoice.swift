
import Foundation

class Invoice {
    
    var id: Int = 0
    var invoiceSerial: String = ""
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
    
    private var invoiceDiscount: Discount? = nil
    var discount: Discount {
        get {
            return invoiceDiscount!
        } set (v) {
            invoiceDiscount = v
        }
    }
    
    
    init(id: Int, invoiceSerial: String, success: Bool, comment: String) {
        self.id = id
        self.invoiceSerial = invoiceSerial
        self.success = success
        self.comment = comment
        
        // inicializar el cliente vacio
        self.invoiceCustomer = Customer(
            id: 0,
            ruc: "",
            name: "",
            lastName: "",
            dob: "",
            phone: "" )
        
        // inicializar el DESCUENTO vacio
        self.invoiceDiscount = Discount(porcentaje: false, description: "", value: 0.0, type: "")
    }
    
}
