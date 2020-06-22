//
//  ViewController.swift
//  SafeMaker
//
//  Created by Noirdemort on 21/06/20.
//  Copyright © 2020 Noirdemort. All rights reserved.
//

import UIKit
import CryptoSwift
import CoreData

class PasswordProcessorViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	var isPasswordGenerated = false
	
	@IBOutlet weak var customPassword: UITextField!
	
	
	@IBOutlet weak var siteURL: UITextField!
	
	
	@IBOutlet weak var datePicker: UIDatePicker!
	
	
	@IBOutlet weak var passwordLabel: UILabel!
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	
	@IBAction func copyPassword(_ sender: Any) {
		UIPasteboard.general.string = passwordLabel.text
	}
	
	
	@IBAction func generatePassword(_ sender: Any) {
		
		if siteURL.text?.isEmpty ?? true {
			let missingValueAlert = createAlert(header: "Site URL is required", message: "Site URl is used for credential storage and password derivation", consolation: "Ok")
			self.present(missingValueAlert, animated: true, completion: nil)
			return
		}
		
		guard let siteName = siteURL.text else  { return }
		
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yy"
		let date = dateFormatter.string(from: datePicker.date)
		
		var savedPassword = UserDefaults.standard.string(forKey: "masterPassword")
		
		if savedPassword == nil {
			savedPassword = self.customPassword.text
		}
		
		
		if savedPassword?.isEmpty ?? true {
			let noPassword = createAlert(header: "Provide Custom Password", message: "Either Master Password or custom password is required", consolation: "OK")
			self.present(noPassword, animated: true, completion: nil)
			return
		}
		
		guard let password = savedPassword else { return }
		self.passwordLabel.text = "Generating Password..."
		
		self.activityIndicator.startAnimating()
		
		DispatchQueue.global(qos: .userInteractive).async {
			
	
			guard let derivedPassword = getDerivedPassword(masterPassword: password, url: siteName, dateString: date) else {
				self.passwordLabel.text = "Some Error Occured"
				self.activityIndicator.stopAnimating()
				return
			}
		
			DispatchQueue.main.async {
				self.activityIndicator.stopAnimating()
				self.passwordLabel.text = derivedPassword
				self.isPasswordGenerated = true
			}
		}
		
	}
	
	
	@IBAction func saveToDB(_ sender: Any) {
		
		if !isPasswordGenerated {
			return
		}
		
		guard let siteName = siteURL.text  else {
			let missingValueAlert = createAlert(header: "Site URL is required", message: "Site URl is used for credential storage and password derivation", consolation: "Ok")
			self.present(missingValueAlert, animated: true, completion: nil)
			return
		}
		
		
		guard let derivedPassword = self.passwordLabel.text else {
			let noDerivation = createAlert(header: "Error", message: "Generate Password first!!", consolation: "Ok")
			self.present(noDerivation, animated: true, completion: nil)
			return
		}
		
		
		let credential = CredentialDB(context: context)
		credential.website = siteName
		credential.password = derivedPassword
		db.saveContext()
		
	}
	
	
}



func createAlert(header: String, message: String, consolation: String)->UIAlertController{
    let alertController = UIAlertController(title: header, message: message, preferredStyle: .alert)
    
    //then we create a default action for the alert...
    //It is actually a button and we have given the button text style and handler
    //currently handler is nil as we are not specifying any handler
    let defaultAction = UIAlertAction(title: consolation ,style: .default, handler: nil)
    
    //now we are adding the default action to our alertcontroller
    alertController.addAction(defaultAction)
    
    return alertController
}


func getDerivedPassword(masterPassword: String, url: String, dateString: String) -> String? {


	let password: Array<UInt8> = Array("\(masterPassword)\(dateString)".utf8)
	let salt: Array<UInt8> = Array(url.utf8)

	do {

		let key = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 4096, keyLength: 128, variant: .sha512).calculate()
		
		var shasum = SHA3(variant: .sha512)
		_ = try shasum.update(withBytes: key)
	
		return (try shasum.finish()).toHexString()
	
	} catch {
		return nil
	}
	
}
