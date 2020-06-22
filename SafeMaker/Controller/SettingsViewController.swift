//
//  SettingsViewController.swift
//  SafeMaker
//
//  Created by Noirdemort on 21/06/20.
//  Copyright © 2020 Noirdemort. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

	
	@IBOutlet weak var newPassword: UITextField!
	
	@IBOutlet weak var confirmNewPassword: UITextField!
	
	@IBOutlet weak var saveInUserDefaults: UISwitch!
	
	@IBOutlet weak var useBiometric: UISwitch!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	
	@IBAction func saveUserDefaultsToggle(_ sender: Any) {
		if !self.saveInUserDefaults.isOn {
			self.useBiometric.isEnabled = false
		} else {
			self.useBiometric.isEnabled = true
		}
	}
	
	
	@IBAction func saveDefaults(_ sender: Any) {
		guard let password = newPassword.text else { return }
		
		guard let confirmPassword = confirmNewPassword.text else {
			let missingValueAlert = createAlert(header: "Confirm Password", message: "Re-enter password to confirm", consolation: "OK")
			self.present(missingValueAlert, animated: true, completion: nil)
			return
		}
		
		if password != confirmPassword {
			let mismatchAlert = createAlert(header: "Error", message: "Password Values dont match", consolation: "Retry")
			self.present(mismatchAlert, animated: true, completion: nil)
			return
		}
		
		UserDefaults.standard.set(password, forKey: "masterPassword")
		
	}
	
	
}
