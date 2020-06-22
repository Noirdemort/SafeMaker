//
//  SetUpViewController.swift
//  SafeMaker
//
//  Created by Noirdemort on 21/06/20.
//  Copyright © 2020 Noirdemort. All rights reserved.
//

import UIKit

class SetUpViewController: UIViewController {
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	
	@IBOutlet weak var masterPassword: UITextField!
		
	
	@IBOutlet weak var useUserDefaults: UISwitch!
	
	
	@IBOutlet weak var useBiometric: UISwitch!
	
	
	@IBAction func saveToUserDefaults(_ sender: Any) {
		if self.useUserDefaults.isOn {
			self.useBiometric.isEnabled = true
			return
		}
		
		self.useBiometric.isEnabled = false
	}
	
	
	@IBAction func saveSetupConfig(_ sender: Any) {
		
		if !useUserDefaults.isOn {
			self.dismiss(animated: true, completion: nil)
			return
		}
		
		UserDefaults.standard.set(masterPassword.text, forKey: "masterPassword")
		self.dismiss(animated: true, completion: nil)
		
		
	}
	
	
}
