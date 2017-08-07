//
//  ViewController.swift
//  FlowDemoApp
//
//  Created by dan on 03/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import UIKit
import Flow

class ViewController: UIViewController {
	
	@IBOutlet public var table: UITableView?

	private var tableManager: TableManager?
	
	var teamReal: TeamModel? = nil
	var teamRealPlayers: [PlayerModel]? = nil
	
	var teamBarcelona: TeamModel? = nil
	var teamBarcelonaPlayers: [PlayerModel]? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Allocate table manager
		self.tableManager = TableManager(table: self.table!)
		
		// Load Real Madrid Players (section 0)
		if let (team,players) = PlayerModel.load("RealMadrid") {
			self.teamReal = team
			self.teamRealPlayers = players
		
			// Create rows
			let rows = Row<PlayerCell>.create(players, { row in
				// Respond to tap
				row.onTap = { _,path in
					let msg = "Tap on player at \(String(path.row)): '\(row.item.fullName)'"
					print(msg)
					return nil
				}
			})
			// Add rows to table (if section is not specified a new section is created for you)
			self.tableManager?.add(rows: rows)

			// Add a custom section view as header
			let realMadridHeader = SectionView<TeamSectionView>(team)
			self.tableManager?.section(atIndex: 0)?.headerView = realMadridHeader
			
		}
	}
	
	@IBAction public func addAnotherTeamOnTop() {
		if let (team,players) = PlayerModel.load("Barcelona") {
			self.teamBarcelona = team
			self.teamRealPlayers = players
			
			// Create players
			let rows = Row<PlayerCell>.create(players, { row in
				row.onTap = { _,path in
					print("Tap on player at \(String(path.row)): '\(row.item.fullName)'")
					return nil
				}
			})
			
			// Add a custom section view as header
			let sectionBarcelona = Section(rows, headerView: SectionView<TeamSectionView>(team))
			self.tableManager?.update(animation: .top, {
				self.tableManager?.insert(section: sectionBarcelona, at: 0)
			})
		}
	}
	
	@IBAction public func addBiographyOnSection() {
		let row_bioReal = Row<MultilineTextCell>(self.teamReal!)
		row_bioReal.onShouldHighlight = { _,_ in
			return false
		}
		self.tableManager?.section(atIndex: 0)?.add(row_bioReal, at: 0)
		self.tableManager?.reloadData()
	}

	@IBAction public func removeFirstRowAnimated() {
		// NOT ANIMATED
		// remove first row not animated
		//self.tableManager?.section(atIndex: 0)?.remove(rowAt: 0)
		// ... you need to reload the data
		//self.tableManager?.reloadData()
		self.tableManager?.update(animation: .left, {
			self.tableManager?.section(atIndex: 0)?.remove(rowAt: 0)
		})
	}
}

