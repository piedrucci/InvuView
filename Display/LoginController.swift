//
//  LoginController.swift
//  Display
//
//  Created by Roberth on 9/18/17.
//  Copyright © 2017 pinneapple. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class LoginController: UIViewController {
    
    
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        txtUsername.text = "lcaesarsvz.pos"
        txtPassword.text = "cc8efd32e2b3c695ecf2835a05e5e75053012dab"
        
        if let apiKey = UserDefaults.standard.string(forKey: "APIKEY") {
            print("apikey: \(apiKey)")
        }else{
            print("no hay apikey")
        }
        
    }
    
    
    
    @IBAction func loginClick(_ sender: Any) {
        
        let url = "https://api.invupos.com/invuApiPos/index.php?r=site/ApiLogin"
        let parameters : [String: String] = [
            "username": txtUsername.text!,
            "password": txtPassword.text!
        ]

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        
        Alamofire.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: nil)
            .responseJSON() { response in
            switch response.result {
                
            case .success:
                let value = JSON(response.result.value!)
                
                UserDefaults.standard.set(String(describing: value["data"]["APIKEY"]), forKey: "APIKEY")
//                self.performSegue(withIdentifier: "segue1", sender: sender)
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
                
            case .failure(let error):
                print("")
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
            }
            
        }
        
    }
    
    
    
    
    //    metodo para cargar las cajas registradoras de la sucursal seleccionada (APIKEY)
//    func getCashRegister() -> Void {
//        let headers: HTTPHeaders = ["APIKEY": api.apiKey]
//        Alamofire.request("https://api.invupos.com/invuApiPos/index.php?r=caja", headers: headers)
//            .responseJSON().then { json -> Void in
//                
//                let cajas = JSON(json)
//                self.cashRegisters = cajas["data"].arrayValue.map{ caja in
//                    return CashRegister(
//                        id: Int(caja["id"].stringValue)!,
//                        name: caja["nombre"].stringValue,
//                        ip_raspberry: caja["ip_raspberry"].stringValue,
//                        ip_precuenta: caja["ip_precuenta"].stringValue
//                    )
//                }
//                
//                
//                print (UserDefaults.standard.integer(forKey: "cashRegisterID"))
//            }
//            .catch{ error in
//                print (error)
//        }
//    }
    

    
    
    
}
