import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON
import AlamofireImage

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
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewPayment: UIView!
    
    
    var data: Array<Item> = []
    var paymentsData: Array<Payment> = []
    var cashRegisters: [CashRegister] = []
    
    private var timer: Timer?
    
    //let appDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray

        view.addSubview(activityIndicator)
        
        viewHeader.isHidden = true
        viewPayment.isHidden = true
        lblComment.isHidden = true
        
//        UserDefaults.standard.set(4, forKey: "cashRegisterID")
        
        toggleVisible(sw: false)
        
//        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(handleMyFunction), userInfo: nil, repeats: false)
        
        showImage()
//        fetchData(cajaID: 3)
//        getCashRegister()
    }
    
//    metodo para mostrar el menu de seleccion de la caja que se desea obtener la ultima orden
    @IBAction func btnMenu(_ sender: UIButton) {
        
        // create the alert
        let alert = UIAlertController(title: "Acciones", message: "Seleccione la caja", preferredStyle: .alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        //        @discardableResult
//        listar las cajas registradoras de la sucursal para que pueda ser seleccionada
        _ = self.cashRegisters.map{ caja in
            //            let cr = caja
            alert.addAction(UIAlertAction(title: caja.name, style: UIAlertActionStyle.default, handler: { action in self.fetchData(caja: caja) } ))
        }
        
        // show the alert
//        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.destructive, handler: {action in exit(0)} ))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    func handleMyFunction() {
        print("update info...")
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var customUITableCell: UITableViewCell?
        
        if (tableView == self.tableView) {
            let customCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
            let item: Item = data[indexPath.row]
            
            customCell.cellCant.text = String(item.quantity)
            customCell.cellDescripcion.text = item.description
            customCell.cellAmount.text = "$"+String(item.price)
            
            if item.modifiers.count > 0 {
                
            }
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
    


//    metodo para cargar y mostrar detalles de la ultima orden para la caja seleccionada (ID)
    func fetchData(caja: CashRegister) {
        toggleActivityIdicator(animate: true)
        
        print("selecciono la caja \(caja.name)")
        //orderTimer.invalidate()
        let url = api.endPoint + "citas/newOrdenCaja/id/"+String(caja.id)
//        let url = api.endPoint + "citas/view/id/68304"
        
        let headers: HTTPHeaders = ["APIKEY": api.apiKey]
        
        Alamofire.request(url, headers: headers).responseData().then
            { json in
                self.loadEntity(json: json)
            }.catch { error in
                print(error)
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
    
//    metodo para parsear todo el JSON devuelto por el request Alamofire
    func loadEntity(json: Data) {
        let json = JSON( data: json )
//        print(json)
        
        if (json["encontro"].bool!){
            
            if json["status"]["descripcion"].string! == "Cerrada" {
                toggleVisible(sw: true)
                
                let invoice = Invoice(
                    id           : Int(json["id"].string!)!,
                    invoiceSerial: json["num_cita"].string!,
                    success      : json["encontro"].bool!,
                    comment      : json["comentario"].string!
                )
                
                // datos del status
                invoice.status = Status(
                    id: Int(json["status"]["id"].string!)!,
                    description: json["status"]["descripcion"].string!
                )
                
                // parsear los ITEMS en la factura
                let items:Array<Item> = json["items"].arrayValue.map {
                    
                    let arrayModifiers = $0["modificadores"].arrayValue
                    let modifiers:Array<Modifier> = arrayModifiers.map{
                        Modifier(
                            id: $0["id"].intValue,
                            quant: $0["cantidad"].intValue,
                            price: $0["costo"].doubleValue,
                            name: $0["nombre"].stringValue
                        )
                    }
                    
                    return Item(
                        id         : $0["item"]["id"].int!,
                        price      : $0["item"]["precio"].double!,
                        description: $0["item"]["nombre"].string!,
                        tax        : $0["item"]["tax"].double!,
                        quant      : $0["cantidad"].int!,
                        modifiers  : modifiers
                    )
                }
                invoice.items = items
                
                
                // parsear los PAGOS en la factura
                let payments: Array<Payment> = json["pagos"].arrayValue.map {
                    Payment(
                        id    : $0["pago"]["tipo"].int!,
                        name  : $0["pago"]["nombre"].string!,
                        amount: Double($0["monto"].string!)!
                    )
                }
                invoice.payments = payments
                
                // datos del empleado
                invoice.employee = Employee(
                    id: Int(json["empleado"]["id"].string!)!,
                    name: json["empleado"]["nombres"].string!,
                    lastName: json["empleado"]["apellidos"].string!
                )
                
                
                // datos del cliente... si ID == 0 (no tiene cliente la factura)
                let customerID = Int(String(describing: json["cliente"]["id"].object))
                if ( customerID! != 0 ) {
                    invoice.customer = Customer(
                        id: Int(json["cliente"]["id"].string!)!,
                        ruc: json["cliente"]["ruc"].string!,
                        name: json["cliente"]["nombres"].string!,
                        lastName: json["cliente"]["apellidos"].string!,
                        dob: json["cliente"]["fecha_nacimiento"].string!,
                        phone: ""
                    )
                }
                
                
                // datos del DESCUENTO
                if (json["descuento"] != JSON.null) {
                    invoice.discount = Discount(
                        id: json["descuento"]["id"].int!,
                        description: json["descuento"]["descripcion"].string!,
                        value: Double(json["descuento"]["valor"].string!)!,
                        type: json["descuento"]["tipo"].string!
                    )
                }
                
                
                // imprimir los resultados
                if (invoice.success) {
//                    lblSerial.text = invoice.invoiceSerial
//                    lblEmployee.text = invoice.employee.fullName
//                    lblCustomer.text = invoice.customer.fullName
                    
                    // calcular el subtotal ITEMS
                    let subtotal = invoice.items.reduce(0.0, { acum, currentItem in
                        acum + currentItem.amountItem
                    })
                    lblSubtotal.text = "$"+String(format: "%.02f", subtotal)
                    
                    // calcular el subtotal TAXS
                    let taxes = invoice.items.reduce(0.0, { acum, currentItem in
                        acum + currentItem.amountTax
                    })
                    lblTax.text = "$"+String(format: "%.02f", taxes)
                    
                    
                    // calcular el total
                    var total = subtotal + taxes
                    
                    
                    // mostrar el total DESCUENTO
                    var totalDiscount = 0.0
                    if invoice.discount.value>0 {
                        totalDiscount = (invoice.discount.value * total)/100
                        total = total - totalDiscount
                        lblStrDiscount.text = "Discount (" + String(format: "%.01f", invoice.discount.value) + "%)"
                    }
                    lblDiscount.text = "$"+String(format: "%.02f", totalDiscount)
                    
                    
                    // mostrar el TOTAL
                    lblTotal.text = "$"+String(format: "%.02f", total)
                    
                    // calcular el total en PAGOS
                    let paid = invoice.payments.reduce(0.0, { acum, currentPayment in
                        acum + currentPayment.amount
                    })
                    lblPaid.text = "$"+String(format: "%.02f", paid)
                    
                    
                    data = invoice.items
                    paymentsData = invoice.payments
                    
                    tableView.reloadData()
                    PaymentTableView.reloadData()
                
                }
            
            } else {
                toggleVisible(sw: false)
            }
            
        } else {
            print(json["msg"].string!)
        }
        
        toggleActivityIdicator(animate: false)
        
    }
    

//    switch para mostrar-ocultar el ActivityIndicator
    func toggleActivityIdicator(animate: Bool) {
        if (animate) {
            activityIndicator.startAnimating()
        }else if (!animate) {
            activityIndicator.stopAnimating()
        }
    }
    
    
//    mostrar / ocultar los objetos en la pantalla
    func toggleVisible(sw: Bool){
        tableView.isHidden = !sw
        PaymentTableView.isHidden = !sw
    }
    
    
    
    func showImage() {
//        Alamofire.request("http://i.imgur.com/w5rkSIj.jpg").responseImage { response in
//            if let catPicture = response.result.value {
////                print("image downloaded: \(catPicture)")
//                logoImage.af_setImage(withURL: <#T##URL#>, placeholderImage: <#T##UIImage?#>, filter: <#T##ImageFilter?#>, progress: <#T##ImageDownloader.ProgressHandler?##ImageDownloader.ProgressHandler?##(Progress) -> Void#>, progressQueue: <#T##DispatchQueue#>, imageTransition: <#T##UIImageView.ImageTransition#>, runImageTransitionIfCached: <#T##Bool#>, completion: <#T##((DataResponse<UIImage>) -> Void)?##((DataResponse<UIImage>) -> Void)?##(DataResponse<UIImage>) -> Void#>)
//            }
//        }
    }
    
    
    

}

