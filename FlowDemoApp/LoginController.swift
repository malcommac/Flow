//
//  ViewController.swift
//  FlowDemoApp
//
//  Created by dan on 03/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import UIKit
import Flow


class LoginController: UIViewController {
	
	@IBOutlet public var table: UITableView?

	private var tableManager: TableManager?
	
	private var isLogged: Bool = false
    
    var credentials = LoginCredentialModel()
	
    public static func create() -> LoginController {
        let u = UIStoryboard(name: "LoginController", bundle: Bundle.main)
        return u.instantiateViewController(withIdentifier: "LoginController") as! LoginController
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
    
		
		// Allocate table manager
        self.table!.rowHeight = UITableViewAutomaticDimension
        self.table!.separatorStyle = .none
        self.table?.tableFooterView = UIView()
		self.tableManager = TableManager(table: self.table!)
		
        self.tableManager?.add(section: self.welcomeSection())
        self.tableManager?.add(section: self.loginSection())
        
        self.tableManager?.reloadData()
	}
    
    private func welcomeSection() -> Section {
        // This is the cell with logo
		let r_logo = Row<CellLogo>(model: Void()) { row in
            // If we have a fixed height we can set it to skip any estimation
            row.rowHeight = 157
            row.onTap = { _ in // Do something on tap
                print("Tap on logo!")
                return nil
            }
        }
		let r_welcome = Row<CellAutosizeText>(model: "Welcome_Text".loc) { row in
            row.onShouldHighlight = { _ in // we want to disable highlight of the row
                return false
            }
        }
        
        let section = Section(rows: [r_logo,r_welcome])
        return section
    }
    
    private func loginSection() -> Section {
        // Login Text Fields
        let login_fields = Row<CellLoginCredential>.create([.email(credentials),.password(credentials)]) { row in
            row.rowHeight = 73
            row.onShouldHighlight = { _ in // we want to disable highlight of the row
                return false
            }
        }
		let login_button = Row<CellButton>(model: "LOGIN!")
//        login_button.onDequeue = { data in
//            (data.0 as! CellButton).onTap = self.executeLogin
//        }
		
		login_button.onDequeue = { row in
			//let cell = (row as! Row<CellButton>).cell

		}
		
        login_button.rowHeight = 70
        login_button.shouldHighlight = false
        
        let loginSection = Section(rows: login_fields)
        loginSection.add(login_button)
        return loginSection
    }
    
    private func loaderSection(forEmail txt: String) -> Section {
		let loader = Row<CellLoader>(model: txt)
        loader.rowHeight = self.table!.frame.size.height - self.table!.contentSize.height
        loader.shouldHighlight = false
        return Section(rows: [loader])
    }
    
    private func executeLogin() {
        self.tableManager?.update(animation: .fade, { () -> (Void) in
            self.tableManager?.remove(sectionAt: 1)
            self.tableManager?.add(section: self.loaderSection(forEmail: self.credentials.email))
       })
    }
}
