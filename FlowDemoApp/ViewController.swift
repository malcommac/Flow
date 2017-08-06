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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let team: TeamModel = TeamModel(name: "REALMADRID", shield: URL(string: "http://www.fotolip.com/wp-content/uploads/2016/05/Real-Madrid-Logo-2.png")!)
		
		let players_list = PlayerModel.load("RealMadrid")
		
		// Section 0
		self.tableManager = TableManager(table: self.table!)
		

		let text_rows = Row<PlayerCell>.create(players_list)
		text_rows.forEach {
			$0.onTap = { _,path in
				let value = "Tap on cell \(String(path.row))"
				print(value)
				return nil
			}
		}
		self.tableManager?.add(rows: text_rows)
		
		let header_view = SectionView<TeamSectionView>(team)
		self.tableManager?.section(atIndex: 0)?.headerView = header_view

		self.tableManager?.reloadData()
	}

}

