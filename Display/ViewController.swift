import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON
import ImageLoader

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var api = Api()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var PaymentTableView: UITableView!
    
    @IBOutlet weak var lblEmployee: UILabel!
    @IBOutlet weak var lblSerial: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblCustomer: UILabel!
    @IBOutlet weak var lblStrDiscount: UILabel!
    
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblTax: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblPaid: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblCashRegisterName: UILabel!
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewPayment: UIView!
    @IBOutlet weak var viewTotal: UIView!
    
    @IBOutlet weak var shopLogo: UIImageView!
    
    var lastId = -1
    
    var data: Array<Item> = []
    var paymentsData: Array<Payment> = []
    
    var numItems = -1
    
    private var timer: Timer?
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray

        view.addSubview(activityIndicator)
        
        viewHeader.isHidden = true
        viewPayment.isHidden = true
        lblComment.isHidden = true
        
        toggleVisible(sw: false)
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedRowHeight = 72
        self.fetchData()
        
//        eliminar las rayas despues del ultimo elemento del tableview
        tableView.tableFooterView = UIView()
        
        lblShopName.text = UserDefaults.standard.string(forKey: "shopName")
        lblCashRegisterName.text = UserDefaults.standard.string(forKey: "cashRegisterDescription")
    }
    
//    metodo para mostrar el menu de seleccion de la caja que se desea obtener la ultima orden
    @IBAction func btnMenu(_ sender: UIButton) {
        self.timer?.invalidate()
        
        UserDefaults.standard.removeObject(forKey: "APIKEY")
        UserDefaults.standard.removeObject(forKey: "cashRegisterID")
        UserDefaults.standard.removeObject(forKey: "pathLogo")
        UserDefaults.standard.removeObject(forKey: "shopName")
        
        
        let window = (UIApplication.shared.delegate as! AppDelegate).window
        if (window?.rootViewController as? LoginController) != nil{
            self.dismiss(animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let controller = storyboard.instantiateViewController(withIdentifier: "logincontroller")
            window?.rootViewController = controller
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        cargar el logo de la tienda (async)
        let pathLogo: String = UserDefaults.standard.string(forKey: "pathLogo")!
        shopLogo.load.request(with: pathLogo)
        
//        print(self.mainView.backgroundColor ?? "-")
//        0.937255 0.937255 0.956863 1
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        var dataCount = 0
        if (tableView == self.tableView) { dataCount = data.count }
        if (tableView == self.PaymentTableView) { dataCount = paymentsData.count }
        return dataCount
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var customUITableCell: UITableViewCell?
        
        if (tableView == self.tableView) {
            let customCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
            customCell.backgroundColor = UIColor.clear
            customCell.contentView.backgroundColor = UIColor.clear
            
            
            let item: Item = data[indexPath.row]
            customCell.cellCant.text = String(item.quantity)
            customCell.cellDescripcion.text = item.description
            customCell.cellAmount.text = "$"+String(format: "%.02f", (item.amountItem + item.amountModifiers) )
            
            
            var modifierDescription: String = ""
            if item.modifiers.count > 0 {
                modifierDescription = item.modifiers.reduce("", { acum, currentItem in
                    acum + currentItem.name + ", "
                })
//                _ = item.modifiers.re map{
//                    modifierDescription = "\(modifierDescription) \($0.name),"
//                }
            }
            customCell.lblModifier.text = modifierDescription
            
            customUITableCell = customCell
            
        } else if (tableView == self.PaymentTableView) {
            let PaymentCell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as! PaymentCustomCell
            let payment: Payment = paymentsData[indexPath.row]
            
            PaymentCell.cellDescription.text = payment.name
            PaymentCell.cellAmount.text = String(payment.amount)
            customUITableCell = PaymentCell
        }
        return customUITableCell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == self.tableView{
            let customCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
            customCell.cellCant.text = "Cant"
            customCell.cellDescripcion.text = "Description"
            customCell.cellAmount.text = "Amount"
            let color: UIColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 0.9)
            customCell.backgroundColor = color
            return customCell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableView{
            return 72
        }
        return 0
    }
    
    

//    metodo para cargar y mostrar detalles de la ultima orden para la caja seleccionada (ID)
    func fetchData(sender : Any? = nil) {
        
        toggleActivityIdicator(animate: true)
        
        let cashRegisterID = UserDefaults.standard.integer(forKey: "cashRegisterID")
        
        if cashRegisterID > 0 {
            //orderTimer.invalidate()
            let url = api.endPoint + "citas/newOrdenCaja/id/"+String(cashRegisterID)
            //        let url = api.endPoint + "citas/view/id/68304"
            
            let headers: HTTPHeaders = ["APIKEY": UserDefaults.standard.string(forKey: "APIKEY") ?? ""]
            
            Alamofire.request(url, headers: headers).responseData().then
                { json in
                    self.loadEntity(json: json)
                }.catch { error in
                    let alertError = UIAlertController(title: "Invu Display", message: "Error getting data", preferredStyle: .alert)
                    alertError.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertError, animated: true, completion: nil)
                    //                print(error)
                    self.toggleActivityIdicator(animate: false)
                    self.btnMenu(self.btnLogout)
            }
        }
        
        
//        Alamofire.request(url, headers: headers).validate()
//            .responseObject { (response: DataResponse<SalesCheck>) in
//            salesCheck = response.result.value!
//            print(salesCheck!.employee!.name)
//                    
//            if salesCheck!.success {
//                print(salesCheck!.checkNum)
//                print(salesCheck!.employee!.name)
//                print(salesCheck!.customer!.name)
//                print(salesCheck!.customer!.lastname)
//                    
//                let listItems = salesCheck!.items
//                    
//                for item in listItems {
//                    print(item.detail!.id)
//                    print(item.detail!.name)
//                    print(item.detail!.price)
//                }
//                    
//                let listPayments = salesCheck!.payments
//                for payment in listPayments {
//                    print(payment.detail!.id)
//                    print(payment.detail!.type)
//                    print(payment.detail!.name)
//                }
//            }else {
//                print(salesCheck!.message)
//            }
//                
//            }

        }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.invalidate()
    }
    
    
    
//    metodo para parsear todo el JSON devuelto por el request Alamofire
    func loadEntity(json: Data) {
        let json = JSON( data: json )
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(ViewController.fetchData(sender:)), userInfo: nil, repeats: false)
        
        if (json["encontro"].boolValue){
            
//            if json["status"]["descripcion"].string! == "Cerrada" {
            
            
                let invoice = Invoice(
                    id           : Int(json["id"].stringValue)!,
                    invoiceSerial: json["num_cita"].stringValue,
                    success      : json["encontro"].boolValue,
                    comment      : json["comentario"].stringValue
                )
            
            
            
                // datos del status
                invoice.status = Status(
                    id: Int(json["status"]["id"].stringValue)!,
                    description: json["status"]["descripcion"].stringValue
                )
                
                // parsear los ITEMS con sus respectivos MODIFICADORES en la factura
                let items:Array<Item> = json["items"].arrayValue.map {
                    
                    var acum: Double = 0.0
                    let arrayModifiers = $0["modificadores"].arrayValue
                    let modifiers:Array<Modifier> = arrayModifiers.map{
                        
                        acum = acum + ($0["cantidad"].doubleValue * $0["costo"].doubleValue)
                        return  Modifier(
                            id: $0["id"].intValue,
                            quant: $0["cantidad"].intValue,
                            price: $0["costo"].doubleValue,
                            name: $0["nombre"].stringValue
                        )
                    }
                    
                    // calcular el subtotal ITEMS
//                    let totalModif = invoice.items.reduce(0.0, { acum, currentItem in
//                        acum + currentItem.amountItem
//                    })
                    
                    return Item(
                        id         : $0["item"]["id"].intValue,
                        price      : $0["item"]["precio"].doubleValue,
                        description: $0["item"]["nombre"].stringValue,
                        tax        : $0["item"]["tax"].doubleValue,
                        quant      : $0["cantidad"].intValue,
                        modifiers  : modifiers,
                        amountMod  : acum
                    )
                }
                invoice.items = items
            
//            _ = items.map{
//                if $0.modifiers.count>0 {
//                    print("tiene modificadores \($0.description)")
//                }
//            }
            
                // parsear los PAGOS en la factura
                let payments: Array<Payment> = json["pagos"].arrayValue.map {
                    Payment(
                        id    : $0["pago"]["tipo"].intValue,
                        name  : $0["pago"]["nombre"].stringValue,
                        amount: Double($0["monto"].stringValue)!
                    )
                }
                invoice.payments = payments
                
                // datos del empleado
                invoice.employee = Employee(
                    id: Int(json["empleado"]["id"].stringValue)!,
                    name: json["empleado"]["nombres"].stringValue,
                    lastName: json["empleado"]["apellidos"].stringValue
                )
                
                
                // datos del cliente... si ID == 0 (no tiene cliente la factura)
                let customerID = Int(String(describing: json["cliente"]["id"].object))
                if ( customerID! != 0 ) {
                    invoice.customer = Customer(
                        id: Int(json["cliente"]["id"].stringValue)!,
                        ruc: json["cliente"]["ruc"].stringValue,
                        name: json["cliente"]["nombres"].stringValue,
                        lastName: json["cliente"]["apellidos"].stringValue,
                        dob: json["cliente"]["fecha_nacimiento"].stringValue,
                        phone: ""
                    )
                }
                
                
                // datos del DESCUENTO
                if (json["descuento"] != JSON.null) {
                    invoice.discount = Discount(
                        id: json["descuento"]["id"].intValue,
                        description: json["descuento"]["descripcion"].stringValue,
                        value: Double(json["descuento"]["valor"].stringValue)!,
                        type: json["descuento"]["tipo"].stringValue
                    )
                }
            
            
            
                
                // imprimir los resultados
                if (invoice.success) {
//                    lblSerial.text = invoice.invoiceSerial
//                    lblEmployee.text = invoice.employee.fullName
//                    lblCustomer.text = invoice.customer.fullName
                    
                    // calcular el subtotal ITEMS
                    let subtotal = invoice.items.reduce(0.0, { acum, currentItem in
                        acum + (currentItem.amountItem + currentItem.amountModifiers)
                    })
                    lblSubtotal.text = "$"+String(format: "%.02f", subtotal)
                    
                    // calcular el subtotal TAXS
                    var taxes = invoice.items.reduce(0.0, { acum, currentItem in
                        acum + currentItem.amountTax
                    })
                    lblTax.text = "$"+String(format: "%.02f", taxes)
                    
                    
                    // calcular el total
                    var acumTotal = subtotal
                    
                    
                    // mostrar el total DESCUENTO
                    var totalDiscount = 0.0
                    if invoice.discount.value>0 {
                        
                        
                        switch invoice.discount.type {
//                            case "PORCENTAGE":
//                                totalDiscount = (invoice.discount.value * acumTotal)/100
//                                lblStrDiscount.text = "Discount (" + String(format: "%.01f", invoice.discount.value) + "%)"
//                                let auxAcumTotal = acumTotal
//                                acumTotal -= totalDiscount
//                                
//                                taxes = (acumTotal * taxes) / auxAcumTotal
//                                lblTax.text = "$"+String(format: "%.02f", taxes)
//                            break
                            case "VALOR":
                                totalDiscount = invoice.discount.value
                                lblStrDiscount.text = "Discount " + invoice.discount.description
                                acumTotal -= totalDiscount
                            break
                            case "LIBRE ($)":
                                totalDiscount = invoice.discount.value
                                lblStrDiscount.text = invoice.discount.description
                                acumTotal -= totalDiscount
                                taxes = (acumTotal * taxes) / acumTotal
                                lblTax.text = "$"+String(format: "%.02f", taxes)
                            break
                        default:
                            totalDiscount = (invoice.discount.value * acumTotal)/100
                            lblStrDiscount.text = "Discount (" + String(format: "%.01f", invoice.discount.value) + "%)"
                            let auxAcumTotal = acumTotal
                            acumTotal -= totalDiscount
                            
                            taxes = (acumTotal * taxes) / auxAcumTotal
                            lblTax.text = "$"+String(format: "%.02f", taxes)
                            break
                        
                        }
//                        acumTotal -= totalDiscount
//                        lblStrDiscount.text = "Discount (" + String(format: "%.01f", invoice.discount.value) + "%)"
                    }
                    lblDiscount.text = "$"+String(format: "%.02f", totalDiscount)
                    acumTotal += taxes
                    
                    
                    
                    
                    
                
                    // mostrar el TOTAL
                    lblTotal.text = "$"+String(format: "%.02f", acumTotal)
                    
                    // calcular el total en PAGOS
                    let paid = invoice.payments.reduce(0.0, { acum, currentPayment in
                        acum + currentPayment.amount
                    })
                    lblPaid.text = "$"+String(format: "%.02f", paid)
                    
                    
                    data = invoice.items
                    paymentsData = invoice.payments
                    
                    
//            ============================================================================
//            ocultar la orden luego de N segundos
                    if invoice.status.description == "Cerrada" && self.lastId == invoice.id{
                        self.tableView.isHidden = true
                        self.lblSubtotal.text = "$0.00"
                        self.lblTax.text = "$0.00"
                        self.lblDiscount.text = "$0.00"
                        self.lblTotal.text = "$0.00"
                        self.lblPaid.text = "$0.00"
                    }else{
                        self.lastId = invoice.id
                        self.tableView.isHidden = false
                    }
                    
                    numItems = items.count
//            ============================================================================
                    

                    
                    tableView.reloadData()
                    PaymentTableView.reloadData()
                
                }

//            } else {
//                toggleVisible(sw: false)
//            }
            
        } else {
            print(json["msg"].stringValue)
        }
        
        toggleActivityIdicator(animate: false)
        
    }
    

//    switch para mostrar-ocultar el ActivityIndicator
    func toggleActivityIdicator(animate: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = animate
        if (animate) {
            activityIndicator.startAnimating()
        }else if (!animate) {
            activityIndicator.stopAnimating()
        }
    }
    
    
//    mostrar / ocultar los objetos en la pantalla
    func toggleVisible(sw: Bool){
        self.tableView.isHidden = !sw
//        self.viewTotal.isHidden = !sw
        self.PaymentTableView.isHidden = !sw
    }
    

}

