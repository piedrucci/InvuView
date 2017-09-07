import UIKit
import Alamofire
import AlamofireObjectMapper

class Api {
    
    private var apiEndPoint = "https://api.invupos.com/invuApiPos/index.php?r="
    private var apiKeyValue = "bd_lcaesarsvzaita"
    
    public var apiKey: String {
        get {
            return apiKeyValue
        } set (v) {
            apiKeyValue = v
        }
    }
    
    public var endPoint: String {
        get {
            return apiEndPoint
        } set (v) {
            apiEndPoint = v
        }
    }
    
    init() {
        
    }
    
    func getInvoice(id: String)->SalesCheck{
        let url = endPoint + "citas/newOrdenCaja/id/" + id
        let headers: HTTPHeaders = ["APIKEY": apiKeyValue]
        var salesCheck:SalesCheck? = nil

        Alamofire.request(url, headers: headers).validate()
            .responseObject { (response: DataResponse<SalesCheck>) in
                salesCheck = response.result.value!

//                if salesCheck!.success {
//                    print(salesCheck!.checkNum)
//                    print(salesCheck!.employee!.name)
//                    print(salesCheck!.customer!.name)
//                    print(salesCheck!.customer!.lastname)
//                    
//                    let listItems = salesCheck!.items
//                    
//                    for item in listItems {
//                        print(item.detail!.id)
//                        print(item.detail!.name)
//                        print(item.detail!.price)
//                    }
//                    
//                    let listPayments = salesCheck!.payments
//                    for payment in listPayments {
//                        print(payment.detail!.id)
//                        print(payment.detail!.type)
//                        print(payment.detail!.name)
//                    }
//                }else {
//                    print(salesCheck!.message)
//                }
                

//            let statusCode = response.response?.statusCode
//            print(statusCode as Any)
//                print(response.request!)
//                print(response.response!)
//                print(response.data!)
//                print(response.result)
//                print(response)
                
//                if let result = response.result.value {
//                    let json = result as! NSDictionary
//                    debugPrint(json)
//                }
                
        }
        
        return salesCheck!
        
    }

}
