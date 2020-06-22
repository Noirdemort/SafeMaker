//
//  HistoryViewController.swift
//  SafeMaker
//
//  Created by Noirdemort on 21/06/20.
//  Copyright © 2020 Noirdemort. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var credentials: [Credential] = []
	
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		self.prefetchCredentials()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return credentials.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "credentialCell", for: indexPath) as! CredentialTableViewCell
		
		let credential = credentials[indexPath.row]
		cell.siteName.text = credential.siteLink
		cell.passwordLabel.text = credential.password
		
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let delete = deleteAction(at: indexPath)
		
		return UISwipeActionsConfiguration(actions: [delete])
	}
	
	func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
		
		let action =  UIContextualAction(style: .normal, title: "❌") { action, view, completion in
			self.deleteRecord(credential: self.credentials[indexPath.row])
			self.credentials.remove(at: indexPath.row)
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
			completion(true)
		}
		
		return action
	}
	
	
	func deleteRecord(credential: Credential) {
		let fetchRequest:NSFetchRequest<CredentialDB> = CredentialDB.fetchRequest()
        do {
            let creds = try context.fetch(fetchRequest)
            if creds.count < 1 {
                return
            }
            
			for cred in creds {
				
				if cred.website ?? "" == credential.siteLink {
					context.delete(cred)
				}
			}
			db.saveContext()

		} catch{
            
		}
	}
	
	func prefetchCredentials(){
        let fetchRequest:NSFetchRequest<CredentialDB> = CredentialDB.fetchRequest()
        do {
            let creds = try context.fetch(fetchRequest)
            if creds.count < 1 {
                return
            }
            
			for cred in creds {
				credentials.append(Credential(siteLink: cred.website!, password: cred.password!))
			}
			
			self.tableView.reloadData()
			
        } catch{
            
		}
    }

}


class CredentialTableViewCell: UITableViewCell {
	
	
	@IBOutlet weak var siteName: UILabel!
	
	
	@IBOutlet weak var passwordLabel: UILabel!
	
	
	@IBAction func copyPassword(_ sender: Any) {
		UIPasteboard.general.string = self.passwordLabel.text
	}
	
}
