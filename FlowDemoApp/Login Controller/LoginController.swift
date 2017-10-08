//
//  ViewController.swift
//  FlowDemoApp
//
//  Created by Daniele Margutti on 03/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import UIKit
import Flow

class LoginController: UIViewController {
	
	@IBOutlet public var table: UITableView?
	
	/// Manager of the table
	private var tableManager: TableManager?
	
	/// Define the content of the table
	///
	/// - login: login content
	/// - recoverLogin: recover account by email
	/// - profile: profile data
	/// - loader: loader for login
	public enum ContentType {
		case login
		case recoverLogin
		case profile
		case loader
	}
	/// Current content of the table
	public var content: ContentType = .login

    /// Helper Properties
	
    /// Credentials used to perform login
    private var credentials = LoginCredentialsModel()
	
	/// Profile struct to fake the logged user
	private var userProfile: UserProfile?

	/// Identifier of the sections
	/// We can assign an identifier to sections in table so we can search and
	/// manipulate them easily.
	private let SECTION_ID_PROFILE = "SECTION_ID_PROFILE" // profile section
	private let SECTION_ID_PROFILE_DETAIL = "SECTION_ID_PROFILE_DETAIL" // profile details section

    /// Create the controller
    ///
    /// - Returns: instance
    public static func create() -> LoginController {
        let u = UIStoryboard(name: "LoginController", bundle: Bundle.main)
        return u.instantiateViewController(withIdentifier: "LoginController") as! LoginController
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()

		// Just setup some fancy things of the table itself
        self.table!.rowHeight = UITableViewAutomaticDimension
        self.table!.separatorStyle = .none
        self.table?.tableFooterView = UIView()
		
		// Allocate the table manager to manage declaratively the table itself
		self.tableManager = TableManager(table: self.table!)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.reloadData()
	}
	
	/// A function which prepare the table itself to be displayed
	public func reloadData() {
		// Remove the content of the table
		self.tableManager?.removeAll()
		// Add sections based upon the content
		self.tableManager?.add(sectionsToAdd: self.tableContent(forType: self.content))
		// Reload data and display it
		self.tableManager?.reloadData()
	}
	
	
	/// This function is used to prepare the content (sections and rows) of the table
	/// based upon the content property.
	///
	/// - Parameter type: type of content
	/// - Returns: list of sections
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
			// ROW: Welcome Text
			// This is an autosizing cell with some welcome text
			let welcome = Row<CellAutosizeText>(model: "Welcome_Text".loc) // the model of the row is a string with text to display
			welcome.onShouldHighlight = { _ in return false } // we can set properties even outside the configuration callback (we have disabled highlight)
			
			// ROW: Credentials
			// This row contains the login textfields (email and password). The model used is the LoginCredentialsModel
			// used to keep and sync data received from the user
			let credentials = Row<CellLoginCredential>(model: self.credentials, { row in
				row.shouldHighlight = false // disable highlight of the row
				// We have hooked `onTapLogin` to our controller's `loginUser` function
				row.onDequeue = { _ in
					row.cell?.onTapLogin = self.loginUser
				}
			})
			// create two sections, one for logo+welcome and another with credentials fields
			return [Section(rows: [logo,welcome]), Section(row: credentials)]
		case .profile:
			// ROW: Profile Info
			// This is a cell with profile's info
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
			// We want also create a custom profile's header, a custom view
			// As like for cells we can set a model; in this case we are not interested
			// so we assign a Void to ProfileHeader's class model.
			let customProfileHeader = SectionView<ProfileHeader>(Void())
			
			// ROWs: List of friends
			// This is a list of cells, one for each friend of the profile
			let row_friends = Row<CellFriend>.create(self.userProfile!.friends, { row in
				row.rowHeight = 60
				row.onTap = { _ in
					self.didTapFriend(row.cell!.friend!)
					return nil
				}
			})
			
			// Create section
			return [Section(rows: [logo]), // one for logo
					Section(id: SECTION_ID_PROFILE, [profile], headerView: customProfileHeader), // one for profile's data
				    Section(row_friends, header: "\(self.userProfile!.friends.count) Friends") // one with the list of friends and a regular header
			]
		case .recoverLogin:
			
			// ROW: Recover data by email
			// This is a cell with a text field with email and a recover button
			let recover = Row<CellRecoverCredentials>(model: Void(), { row in
				row.rowHeight = 180.0
				row.cell?.onTapRecover = { email in
					self.recoverAccount(byEmail: email)
				}
			})
			// Creeate a section with this row
			return [Section(row: recover)]
			
		case .loader:
			
			// ROW: Loader
			// This is a full-height cell with a loader during the login process
			let loader = Row<CellLoader>(model: "Logging in\n '\(self.credentials.email)'", { row in
				row.rowHeight = self.table!.frame.size.height
				row.shouldHighlight = false
			})
			return [Section(row: loader)]
		}
	}
	
	// Helper functions
	
	private func loginUser() {
		// Show loader...
		self.content = .loader
		self.reloadData()
		// And fake login...
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			self.userProfile = UserProfile.loggedUser() // a fake user!
			// Update data
			self.content = .profile
			self.reloadData()
		}
	}
	
	private func didTapFriend(_ friend: FriendUser) {
		let alert = UIAlertController(title: "Tap on friend", message: "Did you know \(friend.firstName)?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Yup", style: .default, handler: { _ in
			print("Okay!")
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
	private var isFullProfileDetailSectionVisible: Bool {
		return self.tableManager?.hasSection(withID: self.SECTION_ID_PROFILE_DETAIL) ?? false
	}
	
	private func toggleFullProfileSection() {
		let profileSection = self.tableManager?.section(forID: SECTION_ID_PROFILE)
		
		if self.isFullProfileDetailSectionVisible == false { // SHOW FULL PROFILE SECTION WITH ROWS
			// Create a row for each profile's detailed attribute
			let profiles_rows = Row<CellAttribute>.create(self.userProfile!.attributes, { row in
				row.onTap = { r in
					print("Tap")
					return nil
				}
			})
			// Group these data in a section
			let profileDetailSection = Section(id: SECTION_ID_PROFILE_DETAIL, rows: profiles_rows)
			
			// Update the table to add it
			self.tableManager?.update(animation: .automatic, {
				self.tableManager?.insert(section: profileDetailSection, at: profileSection!.index! + 1)
			})
		}
		else { // HIDE FULL PROFILE SECTION
			let profileSectionDetail = self.tableManager!.section(forID: SECTION_ID_PROFILE_DETAIL)!
			self.tableManager?.update(animation: .bottom, {
				self.tableManager?.remove(section: profileSectionDetail)
			})
		}
		// In both cases we want to update the "Tap to show/hide details" label into the profile's cell
		profileSection?.reload(.none)
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
