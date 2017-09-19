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
    @IBOutlet weak var button: UIButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let APIKEY = "APIKEY"
    var strAPIKEY: String = ""
    var cashRegisters: [CashRegister] = []
    var validCashRegisterInfo: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        txtUsername.text = "lcaesarsvz.pos"
        txtPassword.text = "invu2017"
//        txtPassword.text = "cc8efd32e2b3c695ecf2835a05e5e75053012dab"
        
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20
        button.layer.backgroundColor = UIColor.gray.cgColor
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if let apiKey = UserDefaults.standard.string(forKey: self.APIKEY) {
            self.validCashRegisterInfo = true
            print("the default APIKEY is \(apiKey)")
        }else{
            self.validCashRegisterInfo = false
            print("no default apiKey set ")
        }
        
        if let defaultCashRegisterID = UserDefaults.standard.string(forKey: "cashRegisterID") {
            self.validCashRegisterInfo = true
            print("the default cash register ID is \(defaultCashRegisterID)")
        }else{
            self.validCashRegisterInfo = false
            print("no default cash register ID set ")
        }
        
//        if self.validCashRegisterInfo {
//            print("caja ya configurada")
//            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//            let controller = storyboard.instantiateViewController(withIdentifier: "viewcontroller")
//            //self.present(controller, animated: false, completion: nil)
//            //self.performSegue(withIdentifier: "segue1", sender: nil)
//            
//        }else{
//            
//        }
        super.viewDidAppear(animated)
        
    }
    
    
    
    
    
    @IBAction func loginClick(_ sender: Any) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        
        let url = "https://api.invupos.com/invuApiPos/index.php?r=site/ApiLogin"
        let parameters : [String: String] = [
            "username": txtUsername.text!,
            "password": self.passwordToSha1(password: txtPassword.text!)
        ]

        Alamofire.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: nil)
            .responseJSON() { response in
            switch response.result {
                
            case .success:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
                
                let json = JSON(response.result.value!)
                
//                fijar el APIKEY por defecto para la APP
//                UserDefaults.standard.set(String(describing: json["data"][self.APIKEY]), forKey: self.APIKEY)
                self.strAPIKEY = String(describing: json["data"][self.APIKEY])
                
                self.getCashRegister()
                
            case .failure(let error):
                print("")
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
            }
            
        }
        
    }
    
    
    
    
    //    metodo para cargar las cajas registradoras de la sucursal seleccionada (APIKEY)
    func getCashRegister() -> Void {
        let headers: HTTPHeaders = ["APIKEY": self.strAPIKEY]
        Alamofire.request("https://api.invupos.com/invuApiPos/index.php?r=caja", headers: headers)
            .responseJSON() { response in
                switch response.result {
                    case .success:
                        let json = JSON(response.result.value!)
                        self.cashRegisters = json["data"].arrayValue.map{ caja in
                            return CashRegister(
                                id: Int(caja["id"].stringValue)!,
                                name: caja["nombre"].stringValue,
                                ip_raspberry: caja["ip_raspberry"].stringValue,
                                ip_precuenta: caja["ip_precuenta"].stringValue
                            )
                        }
//                        predeterminar la caja que va a mostrar el
                        self.showSetCashRegPopup()
                    case .failure(let error):
                        print("")
                        print(error)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.activityIndicator.stopAnimating()
                    }
                }
    }
    
    
    func showSetCashRegPopup() {
        
        // create the alert
        let alert = UIAlertController(title: "Acciones", message: "Seleccione la caja", preferredStyle: .alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        //        @discardableResult
        //        listar las cajas registradoras de la sucursal para que pueda ser seleccionada
        _ = self.cashRegisters.map{ caja in
            //            let cr = caja
            alert.addAction(UIAlertAction(title: caja.name, style: UIAlertActionStyle.default, handler: { action in self.setCashRegister(caja: caja) } ))
        }
        
        // show the alert
        //        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.destructive, handler: {action in exit(0)} ))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func setCashRegister(caja: CashRegister) {
        print("selecciono \(caja.name)")
        UserDefaults.standard.set(self.strAPIKEY, forKey: self.APIKEY)
        UserDefaults.standard.set(caja.id, forKey: "cashRegisterID")
        self.performSegue(withIdentifier: "segue1", sender: self)
    }
    
    
    func passwordToSha1(password : String) -> String{
        let data = password.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
    
}
    

    
    
    

