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
	
	public enum ContentType {
		case login
		case recoverLogin
		case profile
		case loader
	}
	
	@IBOutlet public var table: UITableView?
	private var tableManager: TableManager?
	
	public var content: ContentType = .login

    var credentials = LoginCredentialsModel()
	
	private let SECTION_ID_PROFILE = "SECTION_ID_PROFILE"
	private let SECTION_ID_PROFILE_DETAIL = "SECTION_ID_PROFILE_DETAIL"

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
	}
	
	private var userProfile: UserProfile?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.reloadData()
	}
	
	private func reloadData() {
		self.tableManager?.removeAll()
		self.tableManager?.add(sectionsToAdd: self.tableContent(forType: self.content))
		self.tableManager?.reloadData()
	}
	
	private func tableContent(forType type: ContentType) -> [Section] {
		// ROW #1: Big cell with social's logo
		let logo = Row<CellLogo>(model: Void(), { row in // the configuration callback is the ideal place to configure the cell
			row.onTap = { _ in // Do something on tap of the entire cell
				UIApplication.shared.open(URL(string: "http://www.danielemargutti.com")!, options: [:], completionHandler: nil)
				return nil
			}
		})
		
		switch type {
		case .login:
			// ROW #2: Welcome cell (with autosizing layout)
			let welcome_msg = "Welcome_Text".loc // the model of the cell is the localized messages's String
			let welcome = Row<CellAutosizeText>(model: welcome_msg)
			welcome.onShouldHighlight = { _ in return false } // we can set properties even outside the configuration callback (we have disabled highlight)
			
			// ROW #3: The cell with login and password fields
			// In this case we have specified the height of the row directly on CellLoginCredentials
			// The model of the call is the credentials field.
			let credentials = Row<CellLoginCredential>(model: self.credentials, { row in
				// We have hooked `onTapLogin` to our controller's `loginUser` function
				row.onDequeue = { _ in
					row.cell?.onTapLogin = self.loginUser
				}
				row.shouldHighlight = false
			})
			
			let topSection = Section(rows: [logo,welcome])
			let loginSection = Section(row: credentials)
			return [topSection,loginSection]
		case .profile:
			let profile = Row<CellProfile>(model: self.userProfile!, { row in
				row.onDequeue = { _ in
					if self.isFullProfileDetailSectionVisible == false {
						row.cell?.tapToToggleLabel?.text = "Tap to show full details"
					} else {
						row.cell?.tapToToggleLabel?.text = "Tap to hide details"
					}
				}
				row.onTap = { row in
					self.toggleFullProfileSection()
					return nil
				}
			})
			
			let topSection = Section(rows: [logo])
			let profileSection = Section(id: SECTION_ID_PROFILE, row: profile)
			

			let row_friends = Row<CellFriend>.create(self.userProfile!.friends, { row in
				row.rowHeight = 60
				row.onTap = { _ in
					print("Tap on \(String(describing: row.cell?.friend?.firstName))")
					return nil
				}
			})
			let sectionFriends = Section(rows: row_friends)
			
			return [topSection,profileSection,sectionFriends]
		case .recoverLogin:
			
			// Recover field
			let recover = Row<CellRecoverCredentials>(model: Void(), { row in
				row.rowHeight = 180.0
				row.cell?.onTapRecover = { email in
					self.recoverAccount(byEmail: email)
				}
			})
			
			return [Section(row: recover)]
			
		case .loader:
			let loader = Row<CellLoader>(model: "Login \(self.credentials.email)", { row in
				row.rowHeight = self.table!.frame.size.height
				row.shouldHighlight = false
			})
			return [Section(row: loader)]
		}
	}
	
	private func loginUser() {
		self.content = .loader
		self.reloadData()
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			self.userProfile = UserProfile(firstName: "Mark", lastName: "Zuckerbergo", mood: "I share hard!")
			self.content = .profile
			self.reloadData()
		}
	}
	
	private var isFullProfileDetailSectionVisible: Bool {
		return self.tableManager?.hasSection(withID: self.SECTION_ID_PROFILE_DETAIL) ?? false
	}
	
	private func toggleFullProfileSection() {
		let profileSection = self.tableManager?.section(forID: SECTION_ID_PROFILE)
		
		if self.isFullProfileDetailSectionVisible == false { // SHOW FULL PROFILE SECTION WITH ROWS
			// Create rows for full profile
			let profileDatas = [
				UserProfileAttribute("Job", value: "Facebook Inc"),
				UserProfileAttribute("Position", value: "CEO"),
				UserProfileAttribute("Birthdate", value: "11/06/2017 - 24yrs"),
				UserProfileAttribute("Debugger Level", value: "Top ★★★")
			]
			let profiles_rows = Row<CellAttribute>.create(profileDatas, { row in
				row.onTap = { r in
					print("Tap")
					return nil
				}
			})
			
			let profileDetailSection = Section(id: SECTION_ID_PROFILE_DETAIL, rows: profiles_rows)
			self.tableManager?.update(animation: .automatic, {
				self.tableManager?.insert(section: profileDetailSection, at: profileSection!.index! + 1)
			})
			profileSection?.reload(.automatic)
		}
		else { // HIDE FULL PROFILE SECTION
			let profileSection = self.tableManager!.section(forID: SECTION_ID_PROFILE_DETAIL)!
			self.tableManager?.update(animation: .bottom, {
				self.tableManager?.remove(section: profileSection)
			})
		}

	}
	
	private func recoverAccount(byEmail email: String) {
		
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
