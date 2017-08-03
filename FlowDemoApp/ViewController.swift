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
	private var textNodes: [TextNode] = []
	
	private var expNode: ExpandableNode = ExpandableNode()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Section 0
		let text_nodes = TextNode.load("Data")
		self.tableManager = TableManager(table: self.table!)

		let text_rows = Row<CellMultilineText>.create(text_nodes)
		text_rows.forEach {
			$0.onTap = { _,path in
				let value = "Tap on cell \(String(path.row))"
				print(value)
				return nil
			}
		}
		self.tableManager?.add(rows: text_rows)
		
		let button_row = Row<CellButton>("My Button")
		self.tableManager?.add(row: button_row)
		
		// Section 1
		//let section_1 = Section(header: "Header of Section 1")
		
		let expandable_row = Row<CellExpandable>(self.expNode)
		expandable_row.onTap = { cell, path in
			
			self.tableManager?.update(animation: .top, {
				self.expNode.isExpanded = !self.expNode.isExpanded
			})
			
			return nil
		}
		expandable_row.evaluateRowHeight = {
			return self.expNode.isExpanded ? 150 : 50
		}
		self.tableManager?.add(row: expandable_row)

		self.tableManager?.reloadData()
	}

}

