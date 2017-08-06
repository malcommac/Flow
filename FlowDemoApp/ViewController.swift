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
		

		self.tableManager?.reloadData()
	}

}

