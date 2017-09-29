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
//    invu: ff9907a80070300578eb65a2137670009e8c17cf
//    lcaesars: cc8efd32e2b3c695ecf2835a05e5e75053012dab
    
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var containerLogin: UIView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let APIKEY = "APIKEY"
    var strAPIKEY: String = ""
    var cashRegisters: [CashRegister] = []
    var validCashRegisterInfo: Bool = false
    
    var session: Session!
    
    var showingKey : Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 20
        button.layer.backgroundColor = UIColor.gray.cgColor
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyboardHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    @IBAction func loginClick(_ sender: Any) {
        
        UserDefaults.standard.removeObject(forKey: "pathLogo")
        
        let userName: String = (txtUsername.text?.trimmingCharacters(in: CharacterSet.whitespaces))!
        let password: String = (txtPassword.text?.trimmingCharacters(in: CharacterSet.whitespaces))!
        let alert: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.title = "Login into App"
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.popoverPresentationController?.permittedArrowDirections = .down
        
        if userName == "" {
            alert.message = "Enter the username"
            alert.popoverPresentationController?.sourceView = txtUsername
            alert.popoverPresentationController?.sourceRect = txtUsername.bounds
            self.present(alert, animated: true, completion: nil)
        }else if password == ""{
            alert.message = "Enter the password"
            alert.popoverPresentationController?.sourceView = txtPassword
            alert.popoverPresentationController?.sourceRect = txtPassword.bounds
            
            self.present(alert, animated: true, completion: nil)
        }else{
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            activityIndicator.startAnimating()
            
            let url = "https://api.invupos.com/invuApiPos/index.php?r=site/ApiLogin"
            let passwordSHA1 = self.passwordToSha1(password: password)
            let parameters : [String: String] = [
                "username": userName,
                "password": passwordSHA1
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
                        
                        self.session = Session(
                            id: json["data"]["id"].intValue,
                            username: json["data"]["username"].stringValue,
                            apikey: json["data"][self.APIKEY].stringValue,
                            shopname: json["data"]["nombre_negocio"].stringValue,
                            franchisename: json["data"]["nombreFranquicia"].stringValue,
                            urlimages: json["data"]["urlImagenes"].stringValue
                        )
                        
                        self.getCashRegister()
                        
                    case .failure( _):
                        let alert = UIAlertController(title: "Login Error", message: "Invalid credentials", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        print("")
//                        print(error)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.activityIndicator.stopAnimating()
                    }
                    
            }
        }
        
    }
    
    
    func keyboardShow(sender : Notification){
        let keyboardSize = sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect
        if !showingKey{
            showingKey = true
            self.view.frame.origin.y -= ( (button.frame.origin.y + button.frame.height) - (self.view.frame.height - keyboardSize!.height))

        }
        
    }
    func keyboardHide(sender : Notification){
         self.view.frame.origin.y = 0
        showingKey = false
        
    }
    
    //    metodo para cargar las cajas registradoras de la sucursal seleccionada (APIKEY)
    func getCashRegister() -> Void {
        let headers: HTTPHeaders = ["APIKEY": self.session.apiKey]
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
//        print("selecciono \(caja.name)")
        UserDefaults.standard.set(self.session.apiKey, forKey: self.APIKEY)
        UserDefaults.standard.set(caja.id, forKey: "cashRegisterID")
        UserDefaults.standard.set(self.session.shopName, forKey: "shopName")
        UserDefaults.standard.set(caja.name, forKey: "cashRegisterDescription")
        
        let headers: HTTPHeaders = ["APIKEY": self.session.apiKey]
        let urlConfig = "https://api.invupos.com/invuApiPos/index.php?r=configuraciones"
        Alamofire.request(urlConfig, headers: headers).responseJSON { response in
            
            switch response.result {
                case .success:
                    let json = JSON(response.result.value!)
                    if json.count > 0 {
                        let config = json["data"]
                        self.session.logoName = config["logo"].stringValue
                        UserDefaults.standard.set(self.session.urlImages+self.session.logoName, forKey: "pathLogo")
//                        print(config) // serialized json response
                    }
                case .failure(let error):
                    print(error)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        
        
        self.txtUsername.text = ""
        self.txtPassword.text = ""
        
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
    

    
    
    

