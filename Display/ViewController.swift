import UIKit
import Alamofire
import PromiseKit
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var api = Api()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblEmployee: UILabel!
    @IBOutlet weak var lblSerial: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblCustomer: UILabel!
    
    var data: Array<Item> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let customCell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
        let sd: Item = data[indexPath.row]
        customCell.cellCant.text = String(sd.quantity)
        customCell.cellDescripcion.text = sd.description
        customCell.cellAmount.text = "$"+String(sd.price)
        return customCell
    }
    
    
    @IBAction func showMessage() {
//        let alertController = UIAlertController(title: "Welcome to My First App", message: "Hello World", preferredStyle: UIAlertControllerStyle.alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//        present(alertController, animated: true, completion: nil)
    }
    
    
    func fetchData() {
        toggleActivityIdicator(animate: true)
        
        var url = api.endPoint + "citas/newOrdenCaja/id/4"
        url = api.endPoint + "citas/view/id/67604"
        
        let headers: HTTPHeaders = ["APIKEY": api.apiKey]
//        var salesCheck:SalesCheck? = nil
        
        
//        Alamofire.request("https://jsonplaceholder.typicode.com/posts/1", method: .get).responseString().then
        Alamofire.request(url, headers: headers).responseData().then
            { json in
                self.rr(json: json)
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
    
    func rr(json: Data) {
        let json = JSON( data: json )
        
        let invoice = Invoice(
            id           : Int(json["id"].string!)!,
            invoiceSerial: json["num_cita"].string!,
            success      : json["encontro"].bool!,
            comment      : json["comentario"].string!
        )
        
        
        // parsear los ITEMS en la factura
        let items:Array<Item> = json["items"].arrayValue.map {
            Item(
                id         : $0["item"]["id"].int!,
                price      : $0["item"]["precio"].double!,
                description: $0["item"]["nombre"].string!,
                tax        : $0["item"]["tax"].double!,
                quant      : $0["cantidad"].int!
            )
        }
        invoice.items = items
        
        
        // parsear los PAGOS en la factura
        let payments: Array<Payment> = json["pagos"].arrayValue.map {
            Payment(
                id    : $0["pago"]["tipo"].int!,
                name  : $0["pago"]["nombre"].string!,
                amount: $0["monto"].double!
            )
        }
        invoice.payments = payments
        
        // datos del empleado
        invoice.employee = Employee(
            id: Int(json["empleado"]["id"].string!)!,
            name: json["empleado"]["nombres"].string!,
            lastName: json["empleado"]["apellidos"].string!
        )
        
        
        // datos del cliente
        invoice.customer = Customer(
            id: Int(json["cliente"]["id"].string!)!,
            ruc: json["cliente"]["ruc"].string!,
            name: json["cliente"]["nombres"].string!,
            lastName: json["cliente"]["apellidos"].string!,
            dob: json["cliente"]["fecha_nacimiento"].string!,
            phone: json["cliente"]["telefono1"].string!
        )
        
        // datos del DESCUENTO
        invoice.discount = Discount(
            id: Int(json["descuento"]["id"].string!)!,
            description: json["descuento"]["descripcion"].string!,
            value: Double(json["descuento"]["valor"].string!)!,
            type: json["descuento"]["tipo"].string!
        )
        
        
        // datos del status
        invoice.status = Status(
            id: Int(json["status"]["id"].string!)!,
            description: json["status"]["descripcion"].string!
        )
        
        
        
        
        
        
        
        // imprimir los resultados
        if (invoice.success) {
            lblSerial.text = invoice.invoiceSerial
            lblEmployee.text = invoice.employee.fullName
            lblCustomer.text = invoice.customer.fullName

            data = invoice.items
            
            tableView.reloadData()
            
            toggleActivityIdicator(animate: false)
//            print("esta ocupado: \(busy)")
        }
    }
    
    func toggleActivityIdicator(animate: Bool) {
        if (animate) {
            activityIndicator.startAnimating()
        }else if (!animate) {
            activityIndicator.stopAnimating()
        }
    }

}

