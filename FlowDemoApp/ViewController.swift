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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//let text_nodes = TextNode.load("Data")
		self.tableManager = TableManager(table: self.table!)

	}

}

